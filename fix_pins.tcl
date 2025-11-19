# Complete Pin Assignment Fix for DE0-CV Elevator Controller
# Run this in Quartus TCL Console to fix all pin assignments

# First, remove ALL existing location assignments for our signals
remove_all_instance_assignments -name LOCATION -to clk
remove_all_instance_assignments -name LOCATION -to reset_n
remove_all_instance_assignments -name LOCATION -to inside_buttons[*]
remove_all_instance_assignments -name LOCATION -to mv_up
remove_all_instance_assignments -name LOCATION -to mv_down
remove_all_instance_assignments -name LOCATION -to door_open
remove_all_instance_assignments -name LOCATION -to ssd_hex[*]

# Clock and Reset
set_location_assignment PIN_M9 -to clk
set_location_assignment PIN_U7 -to reset_n

# Inside Buttons - CORRECTED ASSIGNMENTS
set_location_assignment PIN_U13 -to inside_buttons[0]
set_location_assignment PIN_V13 -to inside_buttons[1]
set_location_assignment PIN_T13 -to inside_buttons[2]
set_location_assignment PIN_T12 -to inside_buttons[3]
set_location_assignment PIN_AA15 -to inside_buttons[4]
set_location_assignment PIN_AB15 -to inside_buttons[5]
set_location_assignment PIN_AA14 -to inside_buttons[6]
set_location_assignment PIN_AA13 -to inside_buttons[7]
set_location_assignment PIN_AB13 -to inside_buttons[8]
set_location_assignment PIN_AB12 -to inside_buttons[9]

# Status LEDs
set_location_assignment PIN_AA2 -to mv_up
set_location_assignment PIN_AA1 -to mv_down
set_location_assignment PIN_W2 -to door_open

# Seven-Segment Display HEX0
set_location_assignment PIN_U21 -to ssd_hex[0]
set_location_assignment PIN_V21 -to ssd_hex[1]
set_location_assignment PIN_W22 -to ssd_hex[2]
set_location_assignment PIN_W21 -to ssd_hex[3]
set_location_assignment PIN_Y22 -to ssd_hex[4]
set_location_assignment PIN_Y21 -to ssd_hex[5]
set_location_assignment PIN_AA22 -to ssd_hex[6]

# Set I/O standards
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to reset_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to inside_buttons[*]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to mv_up
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to mv_down
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to door_open
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ssd_hex[*]

puts "Pin assignments complete! Now recompile your project."

