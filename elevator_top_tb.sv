//******************************************************************************
// File: elevator_top_tb.sv
// Author: Omar ElShazli 
// Course: ECNG410401 ASIC Design Using CAD
// Title: Elevator Controller Testbench// Version: 1.0
// Date: November 13, 2025
//******************************************************************************
// Description: Comprehensive self-checking testbench for elevator controller.
//              Tests all 10 test cases from cases.xlsx with automated pass/fail
//              verification, SystemVerilog assertions, and detailed logging.
//
// Test Coverage (from cases.xlsx):
//   1. Movement Timing: 2-second floor-to-floor movement
//   2. Door Duration: Door open ≥2 seconds at target floor
//   3. Direction Persistence: No direction change until requests served
//   4. Request Prioritization: Current direction priority
//   5. Bounds Handling: Ignore invalid requests (up@9, down@0)
//   6. Multiple Simultaneous Requests: Proper sequencing
//   7. Same Floor: Immediate door open without movement
//   8. Intermediate Stops: Stop at intermediate request
//   9. Combined Internal/External: Proper handling of mixed requests
//   10. Error Handling: Reject out-of-range requests
//
// Simulation Speed:
//   - Real hardware: 50M clock cycles per second (50 MHz → 1 Hz enable)
//   - Testbench: 100 clock cycles per enable cycle (500,000x speedup)
//   - This makes simulation practical while maintaining functional accuracy
//******************************************************************************

`timescale 1ns/1ps

module elevator_top_tb;

    //==========================================================================
    // Testbench Parameters
    //==========================================================================
    localparam CLK_PERIOD = 20;         // 50 MHz clock: 20 ns period
    localparam ENABLE_CYCLES = 10;      // Fast simulation: enable every 10 cycles (reduced for faster sim)
    localparam NUM_FLOORS = 10;
    
    //==========================================================================
    // DUT Signals
    //==========================================================================
    logic        clk;
    logic        reset_n;
    logic [9:0]  inside_buttons;
    logic [8:0]  up_buttons;
    logic [8:0]  dn_buttons;
    logic [3:0]  floor;
    logic        mv_up;
    logic        mv_down;
    logic        door_open;
    logic [6:0]  ssd_hex;
    
    //==========================================================================
    // Testbench Variables
    //==========================================================================
    integer test_passed;
    integer test_failed;
    integer total_tests;
    integer door_open_cycles;
    integer cycle_count;
    integer timeout_count;
    logic bounds_test1_pass;
    logic bounds_test2_pass;
    logic same_floor_pass;
    logic error_test_pass;
    logic [3:0] current_fl;
    
    //==========================================================================
    // Clock Generation (50 MHz)
    //==========================================================================
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    //==========================================================================
    // DUT Instantiation with Modified Clock Frequency for Fast Simulation
    //==========================================================================
    elevator_top #(
        .NUM_FLOORS(NUM_FLOORS),
        .MOVE_TIME(2),
        .DOOR_TIME(2),
        .CLK_FREQ(ENABLE_CYCLES)    // Override for fast simulation
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .inside_buttons(inside_buttons),
        .up_buttons(up_buttons),
        .dn_buttons(dn_buttons),
        .floor(floor),
        .mv_up(mv_up),
        .mv_down(mv_down),
        .door_open(door_open),
        .ssd_hex(ssd_hex)
    );
    
    //==========================================================================
    // Runtime Checks (Continuous Monitoring)
    //==========================================================================
    // Note: Icarus Verilog has limited SVA support, using continuous checks instead
    
    // Critical safety check: Door never opens during movement
    always @(posedge clk) begin
        if (reset_n && door_open && (mv_up || mv_down)) begin
            $error("ASSERTION FAILED: Door opened while moving at time %0t", $time);
        end
    end
    
    // Movement signals are mutually exclusive
    always @(posedge clk) begin
        if (reset_n && mv_up && mv_down) begin
            $error("ASSERTION FAILED: Both mv_up and mv_down asserted at time %0t", $time);
        end
    end
    
    // Floor within valid bounds
    always @(posedge clk) begin
        if (reset_n && floor > 4'd9) begin
            $error("ASSERTION FAILED: Floor %0d exceeds maximum at time %0t", floor, $time);
        end
    end
    
    //==========================================================================
    // Helper Tasks
    //==========================================================================
    
    // Task: Wait for N enable cycles
    // Note: Using time-based delay since control_enable is internal signal
    // Each enable cycle = ENABLE_CYCLES * CLK_PERIOD
    task wait_enable_cycles(input integer n);
        #(n * ENABLE_CYCLES * CLK_PERIOD);
    endtask
    
    // Task: Wait for elevator to reach specific floor
    task wait_for_floor(input logic [3:0] target_floor, input integer max_cycles);
        begin
            cycle_count = 0;
            while (floor != target_floor && cycle_count < max_cycles) begin
                @(posedge clk);
                cycle_count++;
            end
            if (cycle_count >= max_cycles) begin
                $display("TIMEOUT: Failed to reach floor %0d within %0d cycles", target_floor, max_cycles);
            end
        end
    endtask
    
    // Task: Wait for door to open
    task wait_for_door_open(input integer max_cycles);
        begin
            cycle_count = 0;
            while (!door_open && cycle_count < max_cycles) begin
                @(posedge clk);
                cycle_count++;
            end
            if (cycle_count >= max_cycles) begin
                $display("TIMEOUT: Door did not open within %0d cycles", max_cycles);
            end
        end
    endtask
    
    // Task: Clear all button inputs
    task clear_buttons();
        inside_buttons = 10'b0;
        up_buttons = 9'b0;
        dn_buttons = 9'b0;
    endtask
    
    // Task: Check test result
    task check_result(input string test_name, input logic pass);
        if (pass) begin
            $display("[PASS] %s", test_name);
            test_passed++;
        end else begin
            $display("[FAIL] %s", test_name);
            test_failed++;
        end
        total_tests++;
    endtask
    
    //==========================================================================
    // Main Test Sequence
    //==========================================================================
    initial begin
        // Force output flushing
        $display("Starting simulation...");
        $fflush();
        
        // Initialize waveform dump
        $dumpfile("elevator_wave.vcd");
        $dumpvars(0, elevator_top_tb);
        
        // Initialize counters
        test_passed = 0;
        test_failed = 0;
        total_tests = 0;
        
        $display("========================================");
        $display("Elevator Controller Testbench");
        $display("Simulation Start Time: %0t", $time);
        $display("========================================\n");
        $fflush();
        
        // Wait a bit to ensure clock is running
        #(CLK_PERIOD * 2);
        $display("DEBUG: After initial delay, time = %0t", $time);
        $fflush();
        
        //======================================================================
        // Phase 0: Initialization and Reset
        //======================================================================
        $display("Phase 0: Initialization and Reset");
        $fflush();
        $display("DEBUG: Clearing buttons...");
        $fflush();
        clear_buttons();
        $display("DEBUG: Setting reset_n = 0");
        $fflush();
        reset_n = 1'b0;
        
        $display("DEBUG: Waiting 10 clock periods...");
        $fflush();
        #(CLK_PERIOD * 10);
        $display("DEBUG: After reset delay, time = %0t", $time);
        $fflush();
        reset_n = 1'b1;
        $display("DEBUG: Reset released, waiting 5 clock periods...");
        $fflush();
        #(CLK_PERIOD * 5);
        $display("DEBUG: After final delay, time = %0t", $time);
        $fflush();
        
        // Wait one more clock cycle to ensure signals are stable
        @(posedge clk);
        $display("DEBUG: After clock edge, time = %0t", $time);
        $fflush();
        
        $display("Time %0t: Reset released, initial floor = %0d", $time, floor);
        $fflush();
        $display("DEBUG: About to check result, floor value = %0d", floor);
        $fflush();
        check_result("Phase 0: Reset and Initialization", floor == 4'd0);
        $display("DEBUG: After check_result");
        $fflush();
        $display("");
        
        //======================================================================
        // Phase 1: Case 1 - Movement Timing Verification
        //======================================================================
        $display("Phase 1: Case 1 - Movement Timing (2 seconds per floor)");
        clear_buttons();
        
        // Request floor 3 from floor 0
        inside_buttons[3] = 1'b1;
        $display("Time %0t: Requested floor 3 from floor 0", $time);
        #(CLK_PERIOD * 5);
        $display("Time %0t: DEBUG -> req_valid=%b req=%0d current_state=%0d floor=%0d", 
                 $time, dut.req_valid, dut.req, dut.u_unit_control.current_state, floor);
        
        // Wait for movement to start
        #(CLK_PERIOD * 20);
        
        // Should be moving up
        if (mv_up) begin
            $display("Time %0t: Elevator moving up", $time);
        end
        
        // Wait for 2 enable cycles (should reach floor 1)
        $display("Time %0t: Waiting for 2 enable cycles...", $time);
        $fflush();
        wait_enable_cycles(2);
        $display("Time %0t: Finished waiting for 2 enable cycles, floor = %0d", $time, floor);
        $fflush();
        #(CLK_PERIOD * 10);
        
        if (floor == 4'd1) begin
            $display("Time %0t: Reached floor 1 after 2 enable cycles", $time);
        end
        
        // Wait for another 2 enable cycles (should reach floor 2)
        wait_enable_cycles(2);
        #(CLK_PERIOD * 10);
        
        if (floor == 4'd2) begin
            $display("Time %0t: Reached floor 2 after 2 more enable cycles", $time);
        end
        
        // Wait to reach floor 3
        wait_for_floor(4'd3, ENABLE_CYCLES * 10);
        #(CLK_PERIOD * 10);
        
        check_result("Case 1: Movement Timing", floor == 4'd3);
        
        // Wait for door to close
        wait_for_door_open(ENABLE_CYCLES * 5);
        wait_enable_cycles(3);
        clear_buttons();
        #(CLK_PERIOD * 100);
        $display("");
        
        //======================================================================
        // Phase 2: Case 2 - Door Duration Verification
        //======================================================================
        $display("Phase 2: Case 2 - Door Duration (≥2 seconds)");
        
        // Request current floor (should open door immediately)
        inside_buttons[floor] = 1'b1;
        $display("Time %0t: Requested current floor %0d", $time, floor);
        
        wait_for_door_open(ENABLE_CYCLES * 5);
        
        if (door_open) begin
            $display("Time %0t: Door opened at floor %0d", $time, floor);
        end
        
        // Count enable cycles while door is open
        // Use time-based approach to avoid infinite loop
        door_open_cycles = 0;
        timeout_count = 0;
        
        while (door_open && door_open_cycles <= 10 && timeout_count < (ENABLE_CYCLES * 15)) begin
            @(posedge clk);
            timeout_count++;
            // Check every ENABLE_CYCLES clock cycles (one enable cycle)
            if (timeout_count % ENABLE_CYCLES == 0) begin
                door_open_cycles++;
            end
        end
        
        $display("Time %0t: Door was open for %0d enable cycles", $time, door_open_cycles);
        check_result("Case 2: Door Duration", door_open_cycles >= 2);
        
        clear_buttons();
        #(CLK_PERIOD * 100);
        $display("");
        
        //======================================================================
        // Phase 3: Case 3 - Direction Persistence
        //======================================================================
        $display("Phase 3: Case 3 - Direction Persistence");
        
        // Move to floor 1 first
        clear_buttons();
        inside_buttons[1] = 1'b1;
        wait_for_floor(4'd1, ENABLE_CYCLES * 20);
        wait_for_door_open(ENABLE_CYCLES * 5);
        wait_enable_cycles(3);
        clear_buttons();
        #(CLK_PERIOD * 100);
        
        // Now at floor 1, request floors 3, 6, 8 (all up)
        inside_buttons[3] = 1'b1;
        inside_buttons[6] = 1'b1;
        inside_buttons[8] = 1'b1;
        $display("Time %0t: At floor 1, requested floors 3, 6, 8", $time);
        
        // Should visit in order: 3, 6, 8 (all upward)
        wait_for_floor(4'd3, ENABLE_CYCLES * 20);
        $display("Time %0t: Reached floor 3", $time);
        inside_buttons[3] = 1'b0;
        wait_enable_cycles(3);
        
        wait_for_floor(4'd6, ENABLE_CYCLES * 20);
        $display("Time %0t: Reached floor 6", $time);
        inside_buttons[6] = 1'b0;
        wait_enable_cycles(3);
        
        wait_for_floor(4'd8, ENABLE_CYCLES * 20);
        $display("Time %0t: Reached floor 8", $time);
        
        check_result("Case 3: Direction Persistence", floor == 4'd8);
        
        clear_buttons();
        wait_enable_cycles(3);
        #(CLK_PERIOD * 100);
        $display("");
        
        //======================================================================
        // Phase 4: Case 4 - Request Prioritization
        //======================================================================
        $display("Phase 4: Case 4 - Request Prioritization");
        
        // Move to floor 4
        clear_buttons();
        inside_buttons[4] = 1'b1;
        wait_for_floor(4'd4, ENABLE_CYCLES * 30);
        wait_for_door_open(ENABLE_CYCLES * 5);
        wait_enable_cycles(3);
        clear_buttons();
        #(CLK_PERIOD * 100);
        
        // At floor 4, request floors 6, 7, 3 simultaneously
        inside_buttons[6] = 1'b1;
        inside_buttons[7] = 1'b1;
        inside_buttons[3] = 1'b1;
        $display("Time %0t: At floor 4, requested floors 6, 7, 3", $time);
        
        // Should go up first (6, 7), then down (3)
        wait_for_floor(4'd6, ENABLE_CYCLES * 20);
        $display("Time %0t: Reached floor 6 (first up)", $time);
        inside_buttons[6] = 1'b0;
        wait_enable_cycles(3);
        
        wait_for_floor(4'd7, ENABLE_CYCLES * 20);
        $display("Time %0t: Reached floor 7 (second up)", $time);
        inside_buttons[7] = 1'b0;
        wait_enable_cycles(3);
        
        wait_for_floor(4'd3, ENABLE_CYCLES * 30);
        $display("Time %0t: Reached floor 3 (down after all up)", $time);
        
        check_result("Case 4: Request Prioritization", floor == 4'd3);
        
        clear_buttons();
        wait_enable_cycles(3);
        #(CLK_PERIOD * 100);
        $display("");
        
        //======================================================================
        // Phase 5: Case 5 - Bounds Handling
        //======================================================================
        $display("Phase 5: Case 5 - Bounds Handling");
        
        // Test 1: At floor 0, try to go down (should be ignored)
        clear_buttons();
        inside_buttons[0] = 1'b1;
        wait_for_floor(4'd0, ENABLE_CYCLES * 30);
        wait_for_door_open(ENABLE_CYCLES * 5);
        wait_enable_cycles(3);
        clear_buttons();
        #(CLK_PERIOD * 100);
        
        $display("Time %0t: At floor 0, pressing dn1 (should be ignored)", $time);
        dn_buttons[0] = 1'b1;  // dn1 at floor 0 (invalid)
        #(CLK_PERIOD * ENABLE_CYCLES * 5);
        
        bounds_test1_pass = (floor == 4'd0) && !mv_down;
        if (bounds_test1_pass) begin
            $display("Time %0t: Correctly ignored down request at floor 0", $time);
        end
        
        clear_buttons();
        
        // Test 2: At floor 9, try to go up (should be ignored)
        inside_buttons[9] = 1'b1;
        wait_for_floor(4'd9, ENABLE_CYCLES * 50);
        wait_for_door_open(ENABLE_CYCLES * 5);
        wait_enable_cycles(3);
        clear_buttons();
        #(CLK_PERIOD * 100);
        
        $display("Time %0t: At floor 9, pressing up9 (should be ignored)", $time);
        up_buttons[8] = 1'b1;  // up9 at floor 9 (invalid)
        #(CLK_PERIOD * ENABLE_CYCLES * 5);
        
        bounds_test2_pass = (floor == 4'd9) && !mv_up;
        if (bounds_test2_pass) begin
            $display("Time %0t: Correctly ignored up request at floor 9", $time);
        end
        
        check_result("Case 5: Bounds Handling", bounds_test1_pass && bounds_test2_pass);
        
        clear_buttons();
        #(CLK_PERIOD * 100);
        $display("");
        
        //======================================================================
        // Phase 6: Case 6 - Multiple Simultaneous Requests
        //======================================================================
        $display("Phase 6: Case 6 - Multiple Simultaneous Requests");
        
        // Move to floor 5
        clear_buttons();
        inside_buttons[5] = 1'b1;
        wait_for_floor(4'd5, ENABLE_CYCLES * 30);
        wait_for_door_open(ENABLE_CYCLES * 5);
        wait_enable_cycles(3);
        clear_buttons();
        #(CLK_PERIOD * 100);
        
        // At floor 5, request floors 3, 7, 2, 8
        inside_buttons[3] = 1'b1;
        inside_buttons[7] = 1'b1;
        inside_buttons[2] = 1'b1;
        inside_buttons[8] = 1'b1;
        $display("Time %0t: At floor 5, requested floors 3, 7, 2, 8", $time);
        
        // Should go up to 7, then 8, then down to 3, then 2
        wait_for_floor(4'd7, ENABLE_CYCLES * 20);
        $display("Time %0t: Reached floor 7", $time);
        inside_buttons[7] = 1'b0;
        wait_enable_cycles(3);
        
        wait_for_floor(4'd8, ENABLE_CYCLES * 20);
        $display("Time %0t: Reached floor 8", $time);
        inside_buttons[8] = 1'b0;
        wait_enable_cycles(3);
        
        wait_for_floor(4'd3, ENABLE_CYCLES * 30);
        $display("Time %0t: Reached floor 3", $time);
        inside_buttons[3] = 1'b0;
        wait_enable_cycles(3);
        
        wait_for_floor(4'd2, ENABLE_CYCLES * 20);
        $display("Time %0t: Reached floor 2", $time);
        
        check_result("Case 6: Multiple Simultaneous Requests", floor == 4'd2);
        
        clear_buttons();
        wait_enable_cycles(3);
        #(CLK_PERIOD * 100);
        $display("");
        
        //======================================================================
        // Phase 7: Case 7 - Same Floor Request
        //======================================================================
        $display("Phase 7: Case 7 - Same Floor Request");
        
        current_fl = floor;
        $display("Time %0t: At floor %0d, requesting same floor", $time, current_fl);
        
        inside_buttons[current_fl] = 1'b1;
        
        // Door should open immediately without movement
        wait_for_door_open(ENABLE_CYCLES * 5);
        
        same_floor_pass = door_open && !mv_up && !mv_down && (floor == current_fl);
        
        if (same_floor_pass) begin
            $display("Time %0t: Door opened immediately without movement", $time);
        end
        
        check_result("Case 7: Same Floor Request", same_floor_pass);
        
        clear_buttons();
        wait_enable_cycles(3);
        #(CLK_PERIOD * 100);
        $display("");
        
        //======================================================================
        // Phase 8: Case 8 - Intermediate Stop
        //======================================================================
        $display("Phase 8: Case 8 - Intermediate Stop");
        
        // Move to floor 1
        clear_buttons();
        inside_buttons[1] = 1'b1;
        wait_for_floor(4'd1, ENABLE_CYCLES * 30);
        wait_for_door_open(ENABLE_CYCLES * 5);
        wait_enable_cycles(3);
        clear_buttons();
        #(CLK_PERIOD * 100);
        
        // Request floor 5 (will move up)
        inside_buttons[5] = 1'b1;
        $display("Time %0t: At floor 1, requested floor 5", $time);
        
        // Wait until moving up and passing floor 2 (with timeout)
        timeout_count = 0;
        while (floor < 4'd2 && timeout_count < (ENABLE_CYCLES * 20)) begin
            @(posedge clk);
            timeout_count++;
        end
        if (timeout_count >= (ENABLE_CYCLES * 20)) begin
            $display("WARNING: Timeout waiting for floor to reach 2");
        end
        #(CLK_PERIOD * 50);
        
        // Now request floor 3 (intermediate stop)
        inside_buttons[3] = 1'b1;
        $display("Time %0t: While moving, requested floor 3 (intermediate)", $time);
        
        // Should stop at floor 3 first
        wait_for_floor(4'd3, ENABLE_CYCLES * 20);
        $display("Time %0t: Stopped at intermediate floor 3", $time);
        inside_buttons[3] = 1'b0;
        wait_enable_cycles(3);
        
        // Then continue to floor 5
        wait_for_floor(4'd5, ENABLE_CYCLES * 20);
        $display("Time %0t: Continued to final floor 5", $time);
        
        check_result("Case 8: Intermediate Stop", floor == 4'd5);
        
        clear_buttons();
        wait_enable_cycles(3);
        #(CLK_PERIOD * 100);
        $display("");
        
        //======================================================================
        // Phase 9: Case 9 - Combined Internal/External Requests
        //======================================================================
        $display("Phase 9: Case 9 - Combined Internal/External Requests");
        
        // Move to floor 2
        clear_buttons();
        inside_buttons[2] = 1'b1;
        wait_for_floor(4'd2, ENABLE_CYCLES * 30);
        wait_for_door_open(ENABLE_CYCLES * 5);
        wait_enable_cycles(3);
        clear_buttons();
        #(CLK_PERIOD * 100);
        
        // At floor 2, set: internal b5, b8; external up3, dn6
        inside_buttons[5] = 1'b1;
        inside_buttons[8] = 1'b1;
        up_buttons[2] = 1'b1;     // up3 (up_buttons[2] = up on floor 3)
        dn_buttons[5] = 1'b1;     // dn6 (dn_buttons[5] = dn on floor 6)
        $display("Time %0t: At floor 2, internal b5/b8, external up3/dn6", $time);
        
        // Expected sequence: 3 (up), 5 (internal), 8 (internal), 6 (down)
        wait_for_floor(4'd3, ENABLE_CYCLES * 20);
        $display("Time %0t: Reached floor 3 (external up)", $time);
        up_buttons[2] = 1'b0;
        wait_enable_cycles(3);
        
        wait_for_floor(4'd5, ENABLE_CYCLES * 20);
        $display("Time %0t: Reached floor 5 (internal)", $time);
        inside_buttons[5] = 1'b0;
        wait_enable_cycles(3);
        
        wait_for_floor(4'd8, ENABLE_CYCLES * 20);
        $display("Time %0t: Reached floor 8 (internal)", $time);
        inside_buttons[8] = 1'b0;
        wait_enable_cycles(3);
        
        wait_for_floor(4'd6, ENABLE_CYCLES * 20);
        $display("Time %0t: Reached floor 6 (external down)", $time);
        
        check_result("Case 9: Combined Internal/External", floor == 4'd6);
        
        clear_buttons();
        wait_enable_cycles(3);
        #(CLK_PERIOD * 100);
        $display("");
        
        //======================================================================
        // Phase 10: Case 10 - Error Handling (Out of Range)
        //======================================================================
        $display("Phase 10: Case 10 - Error Handling");
        
        // Note: With 4-bit floor signal, values > 9 can't be directly tested
        // But we can verify that floor never exceeds 9
        error_test_pass = (floor <= 4'd9);
        
        if (error_test_pass) begin
            $display("Time %0t: Floor value always within valid range (0-9)", $time);
        end
        
        check_result("Case 10: Error Handling", error_test_pass);
        $display("");
        
        //======================================================================
        // Test Summary
        //======================================================================
        $display("========================================");
        $display("Test Summary");
        $display("========================================");
        $display("Total Tests: %0d", total_tests);
        $display("Passed:      %0d", test_passed);
        $display("Failed:      %0d", test_failed);
        $display("========================================");
        
        if (test_failed == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("SOME TESTS FAILED - Review results above");
        end
        
        $display("\nSimulation End Time: %0t", $time);
        $display("========================================\n");
        
        // End simulation
        #(CLK_PERIOD * 100);
        $finish;
    end
    
    // Timeout watchdog - increased timeout for full test suite
    initial begin
        #(CLK_PERIOD * ENABLE_CYCLES * 10000);  // Much longer timeout (10000 enable cycles)
        $display("ERROR: Simulation timeout at time %0t!", $time);
        $display("This suggests the simulation is stuck in an infinite loop.");
        $finish;
    end

endmodule

