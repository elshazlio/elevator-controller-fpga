//******************************************************************************
// File: unit_control.sv
// Author: Omar ElShazli
// Course: ECNG410401 ASIC Design Using CAD
// Title: Elevator Unit Control FSM
// Version: 1.0
// Date: November 13, 2025
//******************************************************************************
// Description: Finite State Machine for elevator movement control, door 
//              control, and floor position updates. Uses control_enable (1 Hz)
//              to gate all timing counters for real-time 2-second intervals.
//
// FSM State Diagram:
//
//                     +-------+
//          +--------->| IDLE  |<----------+
//          |          |       |           |
//          |          +-------+           |
//          |             |  |  |          |
//          |    req==floor  |  |          |
//          |             |  |  |req>floor |
//          |             v  |  v          |
//          |        +--------+  +--------+|
//          |        |  DOOR  |  | MOVING ||
//          |        |  OPEN  |  |   UP   ||
//          |        +--------+  +--------+|
//          |             |          |     |
//          | door_timer>=2  floor==req    |
//          +-------------+          |     |
//                                   v     |
//                              +--------+ |
//                              | MOVING | |
//          floor==req          |  DOWN  |-+
//          +-------------------+--------+
//                    req<floor
//
// State Descriptions:
//   IDLE:        Elevator at rest, door closed/closing. Awaits new request.
//   MOVING_UP:   Elevator moving upward. Increments floor every MOVE_TIME seconds.
//                Asserts mv_up signal. door_open is LOW.
//   MOVING_DOWN: Elevator moving downward. Decrements floor every MOVE_TIME seconds.
//                Asserts mv_down signal. door_open is LOW.
//   DOOR_OPEN:   At target floor, door open for at least DOOR_TIME seconds.
//                Asserts door_open signal. mv_up and mv_down are LOW.
//
// Timing:
//   - MOVE_TIME: Seconds per floor (default 2, implemented as 2 control_enable cycles)
//   - DOOR_TIME: Door open duration in seconds (default 2, ≥2 control_enable cycles)
//   - control_enable: 1 Hz enable signal gates all counters
//
// Critical Rule: door_open NEVER asserted during MOVING_UP or MOVING_DOWN states
//******************************************************************************

module unit_control #(
    parameter NUM_FLOORS = 10,
    parameter MOVE_TIME  = 2,    // Seconds per floor movement
    parameter DOOR_TIME  = 2     // Seconds door stays open
) (
    input  logic       clk,              // 50 MHz system clock
    input  logic       reset_n,          // Active-low reset
    input  logic       control_enable,   // 1 Hz enable for timing
    
    // Request inputs from resolver
    input  logic [3:0] req,              // Requested target floor
    input  logic       req_valid,        // Valid request signal
    
    // Status outputs
    output logic [3:0] floor,            // Current floor position
    output logic [1:0] current_direction, // Direction state for resolver
    output logic       mv_up,            // Moving up indicator
    output logic       mv_down,          // Moving down indicator
    output logic       door_open         // Door open indicator
);

    // FSM state encoding
    typedef enum logic [2:0] {
        IDLE        = 3'b000,
        MOVING_UP   = 3'b001,
        MOVING_DOWN = 3'b010,
        DOOR_OPEN   = 3'b011
    } state_t;
    
    state_t current_state, next_state;
    
    // Direction encoding (exposed to request resolver)
    localparam DIR_IDLE = 2'd0;
    localparam DIR_UP   = 2'd1;
    localparam DIR_DOWN = 2'd2;
    
    // Timing counters
    logic [7:0] movement_counter;    // Counts control_enable cycles for floor movement
    logic [7:0] door_counter;        // Counts control_enable cycles for door open
    
    // Internal floor register
    logic [3:0] floor_reg;
    
    //==========================================================================
    // State Register (Sequential Logic)
    //==========================================================================
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    //==========================================================================
    // Next State Logic (Combinational)
    //==========================================================================
    always_comb begin
        // Default: stay in current state
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (req_valid) begin
                    if (req > floor_reg) begin
                        next_state = MOVING_UP;
                    end else if (req < floor_reg) begin
                        next_state = MOVING_DOWN;
                    end else begin  // req == floor_reg
                        next_state = DOOR_OPEN;
                    end
                end
            end
            
            MOVING_UP: begin
                // Reached target floor
                if (floor_reg == req) begin
                    next_state = DOOR_OPEN;
                end
            end
            
            MOVING_DOWN: begin
                // Reached target floor
                if (floor_reg == req) begin
                    next_state = DOOR_OPEN;
                end
            end
            
            DOOR_OPEN: begin
                // Door timer expired, return to idle
                if (door_counter >= DOOR_TIME) begin
                    next_state = IDLE;
                end
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    
    //==========================================================================
    // Floor Position and Movement Counter (Sequential Logic)
    //==========================================================================
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            floor_reg <= 4'd0;              // Start at ground floor
            movement_counter <= 8'd0;
        end else begin
            case (current_state)
                IDLE: begin
                    movement_counter <= 8'd0;  // Reset counter
                end
                
                MOVING_UP: begin
                    if (control_enable) begin
                        if (movement_counter >= (MOVE_TIME - 1)) begin
                            // Completed movement time, increment floor
                            movement_counter <= 8'd0;
                            if (floor_reg < (NUM_FLOORS - 1)) begin
                                floor_reg <= floor_reg + 1'b1;
                            end
                        end else begin
                            movement_counter <= movement_counter + 1'b1;
                        end
                    end
                end
                
                MOVING_DOWN: begin
                    if (control_enable) begin
                        if (movement_counter >= (MOVE_TIME - 1)) begin
                            // Completed movement time, decrement floor
                            movement_counter <= 8'd0;
                            if (floor_reg > 0) begin
                                floor_reg <= floor_reg - 1'b1;
                            end
                        end else begin
                            movement_counter <= movement_counter + 1'b1;
                        end
                    end
                end
                
                DOOR_OPEN: begin
                    movement_counter <= 8'd0;  // Reset for next move
                end
                
                default: begin
                    movement_counter <= 8'd0;
                end
            endcase
        end
    end
    
    //==========================================================================
    // Door Timer (Sequential Logic)
    //==========================================================================
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            door_counter <= 8'd0;
        end else begin
            if (current_state == DOOR_OPEN) begin
                if (control_enable) begin
                    if (door_counter < DOOR_TIME) begin
                        door_counter <= door_counter + 1'b1;
                    end
                end
            end else begin
                door_counter <= 8'd0;  // Reset when not in DOOR_OPEN
            end
        end
    end
    
    //==========================================================================
    // Output Logic (Combinational)
    //==========================================================================
    always_comb begin
        // Default outputs
        mv_up = 1'b0;
        mv_down = 1'b0;
        door_open = 1'b0;
        current_direction = DIR_IDLE;
        
        case (current_state)
            IDLE: begin
                current_direction = DIR_IDLE;
            end
            
            MOVING_UP: begin
                mv_up = 1'b1;
                current_direction = DIR_UP;
            end
            
            MOVING_DOWN: begin
                mv_down = 1'b1;
                current_direction = DIR_DOWN;
            end
            
            DOOR_OPEN: begin
                door_open = 1'b1;
                // Maintain direction based on where we might go next
                if (req_valid && req > floor_reg)
                    current_direction = DIR_UP;
                else if (req_valid && req < floor_reg)
                    current_direction = DIR_DOWN;
                else
                    current_direction = DIR_IDLE;
            end
            
            default: begin
                current_direction = DIR_IDLE;
            end
        endcase
    end
    
    // Floor output assignment
    assign floor = floor_reg;

endmodule

