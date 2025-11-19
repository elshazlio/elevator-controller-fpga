# QuestaSim/ModelSim Run Script for Elevator Controller
# Place this file in the same directory as your .sv files

# Create work library (or clear if exists)
if {[file exists work]} {
    vdel -all
}
vlib work
vmap work work

# Compile all SystemVerilog files in order
vlog -sv ssd.sv
vlog -sv request_resolver.sv
vlog -sv unit_control.sv
vlog -sv elevator_top.sv
vlog -sv elevator_top_tb.sv

# Start simulation with testbench
vsim -voptargs=+acc work.elevator_top_tb

# Add all signals from testbench and DUT to wave window
add wave -divider "Testbench Signals"
add wave /elevator_top_tb/clk
add wave /elevator_top_tb/reset_n

add wave -divider "DUT Inputs"
add wave -hex /elevator_top_tb/inside_buttons
add wave -hex /elevator_top_tb/up_buttons
add wave -hex /elevator_top_tb/dn_buttons

add wave -divider "DUT Outputs"
add wave -unsigned /elevator_top_tb/floor
add wave /elevator_top_tb/mv_up
add wave /elevator_top_tb/mv_down
add wave /elevator_top_tb/door_open
add wave -hex /elevator_top_tb/ssd_hex

add wave -divider "Internal Signals"
add wave -unsigned /elevator_top_tb/dut/req
add wave /elevator_top_tb/dut/req_valid
add wave /elevator_top_tb/dut/current_direction
add wave /elevator_top_tb/dut/control_enable

add wave -divider "FSM State"
add wave /elevator_top_tb/dut/u_unit_control/current_state
add wave /elevator_top_tb/dut/u_unit_control/next_state

# Configure wave window
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

# Run simulation
run -all

# Zoom to see all waveforms
wave zoom full

# Print completion message
echo "=========================================="
echo "Simulation Complete!"
echo "=========================================="
echo "Check:"
echo "  - Transcript window for test results"
echo "  - Wave window for signal waveforms"
echo "=========================================="

