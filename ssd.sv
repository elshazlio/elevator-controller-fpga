//******************************************************************************
// File: ssd.sv
// Author: Omar ElShazli
// Course: ECNG410401 ASIC Design Using CAD
// Title: Seven-Segment Display Decoder
// Version: 1.0
// Date: September 29, 2025
//******************************************************************************
// Description: BCD to seven-segment display decoder for DE0-CV board.
//              Takes 4-bit BCD input (0000-1001) and produces 7-bit output
//              for controlling seven-segment display. Active LOW outputs.
//******************************************************************************

module ssd (
    input  logic [3:0] BCD,         // 4-bit BCD input (0-9)
    output logic [6:0] SSD          // 7-bit seven-segment output [6:0] = [g:a]
);

    // Seven-segment display mapping: [g f e d c b a]
    // Active LOW - 0 turns segment ON, 1 turns segment OFF
    // Based on common anode display as specified for DE0-CV board
    
    always_comb begin
        case (BCD)
            4'b0000: SSD = 7'b1000000;  // Display "0" - segments: a,b,c,d,e,f ON
            4'b0001: SSD = 7'b1111001;  // Display "1" - segments: b,c ON
            4'b0010: SSD = 7'b0100100;  // Display "2" - segments: a,b,g,e,d ON
            4'b0011: SSD = 7'b0110000;  // Display "3" - segments: a,b,g,c,d ON
            4'b0100: SSD = 7'b0011001;  // Display "4" - segments: f,g,b,c ON
            4'b0101: SSD = 7'b0010010;  // Display "5" - segments: a,f,g,c,d ON
            4'b0110: SSD = 7'b0000010;  // Display "6" - segments: a,f,g,e,d,c ON
            4'b0111: SSD = 7'b1111000;  // Display "7" - segments: a,b,c ON
            4'b1000: SSD = 7'b0000000;  // Display "8" - segments: all ON
            4'b1001: SSD = 7'b0010000;  // Display "9" - segments: a,b,c,d,f,g ON
            default: SSD = 7'b1111111;  // All segments OFF for invalid BCD
        endcase
    end

endmodule
