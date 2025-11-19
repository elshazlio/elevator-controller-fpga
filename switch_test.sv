//******************************************************************************
// File: switch_test.sv
// Simple switch-to-LED test for DE0-CV board
// Use this to verify switches are reading correctly
//******************************************************************************

module switch_test (
    input  logic        clk,                // Not used, but kept for compatibility
    input  logic        reset_n,            // Not used, but kept for compatibility
    input  logic [9:0]  inside_buttons,     // SW[9:0]
    
    output logic        mv_up,              // LEDR[0] = SW[0]
    output logic        mv_down,            // LEDR[1] = SW[1]
    output logic        door_open,          // LEDR[2] = SW[2]
    
    output logic [6:0]  ssd_hex             // HEX0 shows "8" if any switch is ON
);

    // Map first 3 switches directly to first 3 LEDs
    assign mv_up = inside_buttons[0];
    assign mv_down = inside_buttons[1];
    assign door_open = inside_buttons[2];
    
    // Show "8" (all segments ON) if any switch is HIGH, otherwise show "0"
    assign ssd_hex = (|inside_buttons) ? 7'b0000000 : 7'b1000000;

endmodule

