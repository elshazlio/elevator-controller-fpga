//******************************************************************************
// File: request_resolver.sv
// Author: Omar ElShazli
// Course: ECNG410401 ASIC Design Using CAD
// Title: Elevator Request Resolver
// Version: 1.1 - FIXED for Icarus Verilog
// Date: November 14, 2025
//******************************************************************************
// Description: Resolves multiple button requests into a single target floor.
//              FIXED: Removed all variable array indexing to work with Icarus.
//******************************************************************************

module request_resolver #(
    parameter NUM_FLOORS = 10
) (
    // Button inputs
    input  logic [NUM_FLOORS-1:0] inside_buttons,
    input  logic [NUM_FLOORS-2:0] up_buttons,
    input  logic [NUM_FLOORS-2:0] dn_buttons,
    
    // Current elevator state
    input  logic [3:0] current_floor,
    input  logic [1:0] current_direction,
    
    // Resolved request output
    output logic [3:0] req,
    output logic       req_valid
);

    // Direction encoding
    localparam DIR_IDLE = 2'd0;
    localparam DIR_UP   = 2'd1;
    localparam DIR_DOWN = 2'd2;
    
    // Individual floor request signals (explicit to avoid variable indexing)
    logic req_floor0, req_floor1, req_floor2, req_floor3, req_floor4;
    logic req_floor5, req_floor6, req_floor7, req_floor8, req_floor9;
    
    // Boundary filtering logic: ignore invalid directional requests
    // - Down buttons should be ignored if elevator is at or below that floor with nowhere to go down
    // - Up buttons at floor 9 should be ignored (can't go up from top floor)
    logic dn1_valid, dn2_valid, dn3_valid, dn4_valid, dn5_valid;
    logic dn6_valid, dn7_valid, dn8_valid, dn9_valid;
    
    // Down button at floor N is only valid if elevator is above floor N
    // (so it can pick up passenger and take them down)
    assign dn1_valid = dn_buttons[0] && (current_floor > 4'd1);
    assign dn2_valid = dn_buttons[1] && (current_floor > 4'd2);
    assign dn3_valid = dn_buttons[2] && (current_floor > 4'd3);
    assign dn4_valid = dn_buttons[3] && (current_floor > 4'd4);
    assign dn5_valid = dn_buttons[4] && (current_floor > 4'd5);
    assign dn6_valid = dn_buttons[5] && (current_floor > 4'd6);
    assign dn7_valid = dn_buttons[6] && (current_floor > 4'd7);
    assign dn8_valid = dn_buttons[7] && (current_floor > 4'd8);
    assign dn9_valid = dn_buttons[8] && (current_floor > 4'd9); // Always false, but included for completeness
    
    assign req_floor0 = inside_buttons[0];
    assign req_floor1 = inside_buttons[1] | up_buttons[0] | dn1_valid;
    assign req_floor2 = inside_buttons[2] | up_buttons[1] | dn2_valid;
    assign req_floor3 = inside_buttons[3] | up_buttons[2] | dn3_valid;
    assign req_floor4 = inside_buttons[4] | up_buttons[3] | dn4_valid;
    assign req_floor5 = inside_buttons[5] | up_buttons[4] | dn5_valid;
    assign req_floor6 = inside_buttons[6] | up_buttons[5] | dn6_valid;
    assign req_floor7 = inside_buttons[7] | up_buttons[6] | dn7_valid;
    assign req_floor8 = inside_buttons[8] | up_buttons[7] | dn8_valid;
    assign req_floor9 = inside_buttons[9] | dn9_valid;  // No up button at floor 9!
    
    // Helper signals for same-floor check
    logic same_floor_req;
    always_comb begin
        case (current_floor)
            4'd0: same_floor_req = req_floor0;
            4'd1: same_floor_req = req_floor1;
            4'd2: same_floor_req = req_floor2;
            4'd3: same_floor_req = req_floor3;
            4'd4: same_floor_req = req_floor4;
            4'd5: same_floor_req = req_floor5;
            4'd6: same_floor_req = req_floor6;
            4'd7: same_floor_req = req_floor7;
            4'd8: same_floor_req = req_floor8;
            4'd9: same_floor_req = req_floor9;
            default: same_floor_req = 1'b0;
        endcase
    end
    
    // Priority-based request resolution
    always_comb begin
        req = current_floor;
        req_valid = 1'b0;
        
        // Same floor request first
        if (same_floor_req) begin
            req = current_floor;
            req_valid = 1'b1;
        end
        // Moving up or idle: prioritize higher floors
        else if (current_direction == DIR_UP || current_direction == DIR_IDLE) begin
            // Check floors from top down
            if (req_floor9) begin
                req = 4'd9; req_valid = 1'b1;
            end else if (req_floor8) begin
                req = 4'd8; req_valid = 1'b1;
            end else if (req_floor7) begin
                req = 4'd7; req_valid = 1'b1;
            end else if (req_floor6) begin
                req = 4'd6; req_valid = 1'b1;
            end else if (req_floor5) begin
                req = 4'd5; req_valid = 1'b1;
            end else if (req_floor4) begin
                req = 4'd4; req_valid = 1'b1;
            end else if (req_floor3) begin
                req = 4'd3; req_valid = 1'b1;
            end else if (req_floor2) begin
                req = 4'd2; req_valid = 1'b1;
            end else if (req_floor1) begin
                req = 4'd1; req_valid = 1'b1;
            end else if (req_floor0) begin
                req = 4'd0; req_valid = 1'b1;
            end
        end
        // Moving down: prioritize lower floors
        else if (current_direction == DIR_DOWN) begin
            // Check floors from bottom up
            if (req_floor0) begin
                req = 4'd0; req_valid = 1'b1;
            end else if (req_floor1) begin
                req = 4'd1; req_valid = 1'b1;
            end else if (req_floor2) begin
                req = 4'd2; req_valid = 1'b1;
            end else if (req_floor3) begin
                req = 4'd3; req_valid = 1'b1;
            end else if (req_floor4) begin
                req = 4'd4; req_valid = 1'b1;
            end else if (req_floor5) begin
                req = 4'd5; req_valid = 1'b1;
            end else if (req_floor6) begin
                req = 4'd6; req_valid = 1'b1;
            end else if (req_floor7) begin
                req = 4'd7; req_valid = 1'b1;
            end else if (req_floor8) begin
                req = 4'd8; req_valid = 1'b1;
            end else if (req_floor9) begin
                req = 4'd9; req_valid = 1'b1;
            end
        end
    end

endmodule
