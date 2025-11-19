//******************************************************************************
// File: elevator_top.sv
// Author:Omar ElShazli
// Course: ECNG410401 ASIC Design Using CAD
// Title: Elevator Controller Top-Level Module
// Version: 1.0
// Date: November 13, 2025
//******************************************************************************
// Description: Top-level integration module for the elevator controller.
//              Integrates request_resolver, unit_control, and ssd modules.
//              Includes clock divider to generate 1 Hz control_enable from
//              50 MHz system clock for timing control.
//
// Module Hierarchy:
//   elevator_top
//     ├── request_resolver: Button input processing and priority resolution
//     ├── unit_control: FSM for movement and door control
//     └── ssd: Seven-segment display decoder (floor display)
//
// Clock Divider:
//   - Divides 50 MHz clock to 1 Hz control_enable
//   - Counter: 0 to 49,999,999 (50 million cycles = 1 second)
//   - control_enable pulses high for 1 clock cycle every second
//
// Pin Assignments (per pin_assignment_guide.csv for DE0-CV):
//   - CLOCK_50: PIN_M9
//   - RESET_N: PIN_P22
//   - SW0-SW9: PIN_U13, PIN_V13, PIN_T13, PIN_T12, PIN_AA15, PIN_AB15,
//              PIN_AA14, PIN_AA13, PIN_AB13, PIN_AB12
//   - LEDR0-LEDR2: PIN_AA2, PIN_AA1, PIN_W2
//   - HEX0[0-6]: PIN_U21, PIN_V21, PIN_W22, PIN_W21, PIN_Y22, PIN_Y21, PIN_AA22
//******************************************************************************

module elevator_top #(
    parameter NUM_FLOORS = 10,
    parameter MOVE_TIME  = 2,
    parameter DOOR_TIME  = 2,
    parameter CLK_FREQ   = 50_000_000   // 50 MHz
) (
    // System inputs
    input  logic        clk,                    // 50 MHz system clock
    input  logic        reset_n,                // Active-low reset
    
    // Button inputs
    input  logic [9:0]  inside_buttons,         // Inside elevator buttons (b0-b9)
    input  logic [8:0]  up_buttons,             // External up buttons (up1-up9)
    input  logic [8:0]  dn_buttons,             // External down buttons (dn1-dn9)
    
    // Status outputs
    output logic [3:0]  floor,                  // Current floor (0-9)
    output logic        mv_up,                  // Moving up indicator (to LEDR0)
    output logic        mv_down,                // Moving down indicator (to LEDR1)
    output logic        door_open,              // Door open indicator (to LEDR2)
    
    // Seven-segment display output
    output logic [6:0]  ssd_hex                 // Seven-segment display (to HEX0)
);

    //==========================================================================
    // Internal Signals
    //==========================================================================
    
    // Clock divider signals
    logic [25:0] clk_counter;           // Counter for clock division (0 to 49,999,999)
    logic control_enable;               // 1 Hz enable signal
    
    // Request resolver to unit control signals
    logic [3:0] req;                    // Resolved target floor
    logic req_valid;                    // Valid request signal
    
    // Unit control to request resolver signals
    logic [1:0] current_direction;      // Current direction (IDLE/UP/DOWN)
    
    //==========================================================================
    // Clock Divider: 50 MHz → 1 Hz control_enable
    //==========================================================================
    // Generates a 1-cycle pulse every 1 second for timing control
    // Counter counts from 0 to 49,999,999 (50 million cycles = 1 second at 50 MHz)
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            clk_counter <= 26'd0;
            control_enable <= 1'b0;
        end else begin
            if (clk_counter >= (CLK_FREQ - 1)) begin
                clk_counter <= 26'd0;
                control_enable <= 1'b1;     // Pulse high for 1 cycle
            end else begin
                clk_counter <= clk_counter + 1'b1;
                control_enable <= 1'b0;
            end
        end
    end
    
    //==========================================================================
    // Request Resolver Instance
    //==========================================================================
    // Resolves multiple button requests into single target floor with priority
    
    request_resolver #(
        .NUM_FLOORS(NUM_FLOORS)
    ) u_request_resolver (
        // Button inputs
        .inside_buttons(inside_buttons),
        .up_buttons(up_buttons),
        .dn_buttons(dn_buttons),
        
        // Current elevator state
        .current_floor(floor),
        .current_direction(current_direction),
        
        // Resolved request output
        .req(req),
        .req_valid(req_valid)
    );
    
    //==========================================================================
    // Unit Control Instance
    //==========================================================================
    // FSM for elevator movement, door control, and floor tracking
    
    unit_control #(
        .NUM_FLOORS(NUM_FLOORS),
        .MOVE_TIME(MOVE_TIME),
        .DOOR_TIME(DOOR_TIME)
    ) u_unit_control (
        .clk(clk),
        .reset_n(reset_n),
        .control_enable(control_enable),
        
        // Request inputs
        .req(req),
        .req_valid(req_valid),
        
        // Status outputs
        .floor(floor),
        .current_direction(current_direction),
        .mv_up(mv_up),
        .mv_down(mv_down),
        .door_open(door_open)
    );
    
    //==========================================================================
    // Seven-Segment Display Instance
    //==========================================================================
    // Converts floor number (0-9) to seven-segment display format
    
    ssd u_ssd (
        .BCD(floor),
        .SSD(ssd_hex)
    );

endmodule

