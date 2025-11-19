//******************************************************************************
// File: elevator_top_fpga_debug.sv
// Author: Omar ElShazli
// Title: FPGA Debug Wrapper for Elevator Controller
// Version: 1.0 DEBUG
// Date: November 19, 2025
//******************************************************************************
// Description: DEBUG version that exposes internal signals to LEDs
//              to help diagnose why switches aren't working.
//
// DEBUG OUTPUTS:
//   - LEDR[0]: mv_up (normal)
//   - LEDR[1]: mv_down (normal)
//   - LEDR[2]: door_open (normal)
//   - LEDR[3]: control_enable pulse (should blink every 1 second)
//   - LEDR[4]: req_valid (shows if any valid request is detected)
//   - LEDR[5]: inside_buttons[0] OR'd with inside_buttons[5] (test switch read)
//   - LEDR[6]: Indicates any switch is HIGH
//   - LEDR[7]: reset_n status (should be ON if not in reset)
//******************************************************************************

module elevator_top_fpga_debug #(
    parameter NUM_FLOORS = 10,
    parameter MOVE_TIME  = 2,
    parameter DOOR_TIME  = 2,
    parameter CLK_FREQ   = 50_000_000   // 50 MHz
) (
    // System inputs
    input  logic        clk,                    // 50 MHz system clock from PIN_M9
    input  logic        reset_n,                // Active-low reset from KEY[0] (PIN_U7)
    
    // Button inputs (only inside buttons for FPGA demo)
    input  logic [9:0]  inside_buttons,         // Mapped to SW[9:0]
    
    // Status outputs (normal + debug)
    output logic        mv_up,                  // Moving up indicator (LEDR[0])
    output logic        mv_down,                // Moving down indicator (LEDR[1])
    output logic        door_open,              // Door open indicator (LEDR[2])
    output logic        debug_control_enable,   // DEBUG: LEDR[3] - 1 Hz pulse
    output logic        debug_req_valid,        // DEBUG: LEDR[4] - valid request
    output logic        debug_switch_test,      // DEBUG: LEDR[5] - test switches
    output logic        debug_any_switch,       // DEBUG: LEDR[6] - any switch high
    output logic        debug_reset_status,     // DEBUG: LEDR[7] - reset_n value
    
    // Seven-segment display output
    output logic [6:0]  ssd_hex                 // Seven-segment display (HEX0)
);

    //==========================================================================
    // Internal Signals
    //==========================================================================
    
    // Unused external button inputs (tied to ground)
    logic [8:0] up_buttons_unused;
    logic [8:0] dn_buttons_unused;
    
    // Floor output (used internally, displayed on HEX0)
    logic [3:0] floor_internal;
    
    // Control enable from clock divider
    logic control_enable_internal;
    
    // Request signals from resolver
    logic [3:0] req_internal;
    logic req_valid_internal;
    
    // Direction from unit control
    logic [1:0] current_direction_internal;
    
    // Tie unused inputs to ground (no external up/down buttons)
    assign up_buttons_unused = 9'b000000000;
    assign dn_buttons_unused = 9'b000000000;
    
    //==========================================================================
    // DEBUG: Expose Internal Signals to LEDs
    //==========================================================================
    assign debug_control_enable = control_enable_internal;  // LEDR[3] - blinks every 1 sec
    assign debug_req_valid = req_valid_internal;            // LEDR[4] - shows valid request
    assign debug_switch_test = inside_buttons[0] | inside_buttons[5]; // LEDR[5] - test SW0 or SW5
    assign debug_any_switch = |inside_buttons;              // LEDR[6] - any switch is high
    assign debug_reset_status = reset_n;                    // LEDR[7] - should be HIGH when not reset
    
    //==========================================================================
    // Clock Divider (copied from elevator_top.sv)
    //==========================================================================
    logic [25:0] clk_counter;
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 26'd0;
            control_enable_internal <= 1'b0;
        end else begin
            if (clk_counter >= (CLK_FREQ - 1)) begin
                clk_counter <= 26'd0;
                control_enable_internal <= 1'b1;     // Pulse high for 1 cycle
            end else begin
                clk_counter <= clk_counter + 1'b1;
                control_enable_internal <= 1'b0;
            end
        end
    end
    
    //==========================================================================
    // Request Resolver Instance
    //==========================================================================
    request_resolver #(
        .NUM_FLOORS(NUM_FLOORS)
    ) u_request_resolver (
        .inside_buttons(inside_buttons),
        .up_buttons(up_buttons_unused),
        .dn_buttons(dn_buttons_unused),
        .current_floor(floor_internal),
        .current_direction(current_direction_internal),
        .req(req_internal),
        .req_valid(req_valid_internal)
    );
    
    //==========================================================================
    // Unit Control Instance
    //==========================================================================
    unit_control #(
        .NUM_FLOORS(NUM_FLOORS),
        .MOVE_TIME(MOVE_TIME),
        .DOOR_TIME(DOOR_TIME)
    ) u_unit_control (
        .clk(clk),
        .reset_n(reset_n),
        .control_enable(control_enable_internal),
        .req(req_internal),
        .req_valid(req_valid_internal),
        .floor(floor_internal),
        .current_direction(current_direction_internal),
        .mv_up(mv_up),
        .mv_down(mv_down),
        .door_open(door_open)
    );
    
    //==========================================================================
    // Seven-Segment Display Instance
    //==========================================================================
    ssd u_ssd (
        .BCD(floor_internal),
        .SSD(ssd_hex)
    );

endmodule

