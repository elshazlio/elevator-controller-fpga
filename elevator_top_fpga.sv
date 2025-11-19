//******************************************************************************
// File: elevator_top_fpga.sv
// Author: Omar ElShazli
// Course: ECNG410401 ASIC Design Using CAD
// Title: FPGA Wrapper for Elevator Controller
// Version: 1.0
// Date: November 14, 2025
//******************************************************************************
// Description: Simplified wrapper for FPGA implementation on DE0-CV board.
//              Ties unused up_buttons and dn_buttons inputs to ground since
//              the DE0-CV has limited input resources (only 10 switches).
//              
//              This wrapper allows testing the core elevator functionality
//              using only the inside buttons (mapped to slide switches).
//
// Pin Mapping Summary:
//   - clk:             PIN_M9  (CLOCK_50)
//   - reset_n:         PIN_U7  (KEY[0])
//   - inside_buttons:  PIN_U13 to PIN_AB12 (SW[0] to SW[9])
//   - mv_up:           PIN_AA2 (LEDR[0])
//   - mv_down:         PIN_AA1 (LEDR[1])
//   - door_open:       PIN_W2  (LEDR[2])
//   - ssd_hex:         PIN_U21 to PIN_AA22 (HEX0[0] to HEX0[6])
//******************************************************************************

module elevator_top_fpga #(
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
    
    // Status outputs
    output logic        mv_up,                  // Moving up indicator (LEDR[0])
    output logic        mv_down,                // Moving down indicator (LEDR[1])
    output logic        door_open,              // Door open indicator (LEDR[2])
    
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
    
    // Tie unused inputs to ground (no external up/down buttons)
    assign up_buttons_unused = 9'b000000000;
    assign dn_buttons_unused = 9'b000000000;
    
    //==========================================================================
    // Elevator Top Module Instance
    //==========================================================================
    // Instantiate the full elevator controller with unused inputs tied off
    
    elevator_top #(
        .NUM_FLOORS(NUM_FLOORS),
        .MOVE_TIME(MOVE_TIME),
        .DOOR_TIME(DOOR_TIME),
        .CLK_FREQ(CLK_FREQ)
    ) u_elevator_top (
        // System inputs
        .clk(clk),
        .reset_n(reset_n),
        
        // Button inputs
        .inside_buttons(inside_buttons),
        .up_buttons(up_buttons_unused),         // Tied to ground
        .dn_buttons(dn_buttons_unused),         // Tied to ground
        
        // Status outputs
        .floor(floor_internal),                 // Internal only (shown on HEX0)
        .mv_up(mv_up),
        .mv_down(mv_down),
        .door_open(door_open),
        
        // Seven-segment display
        .ssd_hex(ssd_hex)
    );

endmodule


