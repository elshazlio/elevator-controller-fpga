# FPGA Implementation Guide - Elevator Controller
## DE0-CV Board (Cyclone V 5CEBA4F23C7)

---

## Table of Contents
1. [Overview](#overview)
2. [Hardware Requirements](#hardware-requirements)
3. [Signal Mapping Strategy](#signal-mapping-strategy)
4. [Complete Pin Assignment Table](#complete-pin-assignment-table)
5. [Quartus Step-by-Step Instructions](#quartus-step-by-step-instructions)
6. [Pin Assignment Methods](#pin-assignment-methods)
7. [Programming the FPGA](#programming-the-fpga)
8. [Testing on Hardware](#testing-on-hardware)
9. [Troubleshooting](#troubleshooting)

---

## Overview

This guide walks you through implementing the **Elevator Controller** design on the Altera DE0-CV FPGA board using Quartus Prime. The design has been verified in simulation and is ready for hardware implementation.

### Design Files Required
- `elevator_top.sv` - Top-level module
- `request_resolver.sv` - Request priority logic
- `unit_control.sv` - FSM for elevator control
- `ssd.sv` - Seven-segment display decoder

---

## Hardware Requirements

- **FPGA Board**: Altera DE0-CV (Cyclone V 5CEBA4F23C7)
- **Software**: Intel Quartus Prime (Version 20.1 or later recommended)
- **USB Cable**: USB Blaster for programming
- **PC**: Windows/Linux/Mac with Quartus installed

---

## Signal Mapping Strategy

### Challenge
The elevator controller has **28 button inputs** total:
- 10 inside buttons (b0-b9)
- 9 up buttons (up1-up9)  
- 9 down buttons (dn1-dn9)

The DE0-CV board has limited input resources:
- 10 slide switches (SW0-SW9)
- 4 push buttons (KEY0-KEY3)

### Solution: Simplified Mapping

For FPGA demonstration, we'll use this **practical mapping**:

| Signal Group | DE0-CV Resource | Count | Usage |
|--------------|-----------------|-------|-------|
| **Inside Buttons** | SW[9:0] | 10 | Primary control - flip switch to request floor |
| **Up Buttons** | Not mapped | 9 | *Optional: Can add external switches* |
| **Down Buttons** | Not mapped | 9 | *Optional: Can add external switches* |
| **Clock** | CLOCK_50 | 1 | 50 MHz system clock |
| **Reset** | KEY[0] (active-low) | 1 | Push to reset elevator |
| **Status LEDs** | LEDR[2:0] | 3 | Show mv_up, mv_down, door_open |
| **Floor Display** | HEX0 | 7-seg | Current floor number |

> **Note**: This simplified mapping allows you to test the core elevator functionality using only the inside buttons. The elevator will move to requested floors and demonstrate the FSM behavior.

---

## Complete Pin Assignment Table

### Input Pins

| Signal Name | FPGA Pin | DE0-CV Component | Description |
|-------------|----------|------------------|-------------|
| `clk` | **PIN_M9** | CLOCK_50 | 50 MHz system clock |
| `reset_n` | **PIN_U7** | KEY[0] | Active-low reset (push button) |
| `inside_buttons[0]` | **PIN_U13** | SW[0] | Inside button for floor 0 |
| `inside_buttons[1]` | **PIN_V13** | SW[1] | Inside button for floor 1 |
| `inside_buttons[2]` | **PIN_T13** | SW[2] | Inside button for floor 2 |
| `inside_buttons[3]` | **PIN_T12** | SW[3] | Inside button for floor 3 |
| `inside_buttons[4]` | **PIN_AA15** | SW[4] | Inside button for floor 4 |
| `inside_buttons[5]` | **PIN_AB15** | SW[5] | Inside button for floor 5 |
| `inside_buttons[6]` | **PIN_AA14** | SW[6] | Inside button for floor 6 |
| `inside_buttons[7]` | **PIN_AA13** | SW[7] | Inside button for floor 7 |
| `inside_buttons[8]` | **PIN_AB13** | SW[8] | Inside button for floor 8 |
| `inside_buttons[9]` | **PIN_AB12** | SW[9] | Inside button for floor 9 |
| `up_buttons[8:0]` | **GND** | Tied low | Not used in basic implementation |
| `dn_buttons[8:0]` | **GND** | Tied low | Not used in basic implementation |

### Output Pins

| Signal Name | FPGA Pin | DE0-CV Component | Description |
|-------------|----------|------------------|-------------|
| `mv_up` | **PIN_AA2** | LEDR[0] | LED ON when moving up |
| `mv_down` | **PIN_AA1** | LEDR[1] | LED ON when moving down |
| `door_open` | **PIN_W2** | LEDR[2] | LED ON when door is open |
| `ssd_hex[0]` | **PIN_U21** | HEX0[0] | Seven-segment bit 0 (segment a) |
| `ssd_hex[1]` | **PIN_V21** | HEX0[1] | Seven-segment bit 1 (segment b) |
| `ssd_hex[2]` | **PIN_W22** | HEX0[2] | Seven-segment bit 2 (segment c) |
| `ssd_hex[3]` | **PIN_W21** | HEX0[3] | Seven-segment bit 3 (segment d) |
| `ssd_hex[4]` | **PIN_Y22** | HEX0[4] | Seven-segment bit 4 (segment e) |
| `ssd_hex[5]` | **PIN_Y21** | HEX0[5] | Seven-segment bit 5 (segment f) |
| `ssd_hex[6]` | **PIN_AA22** | HEX0[6] | Seven-segment bit 6 (segment g) |

### Unused Outputs (Optional - for debugging)

| Signal Name | FPGA Pin | DE0-CV Component | Description |
|-------------|----------|------------------|-------------|
| `floor[0]` | **PIN_N2** | LEDR[4] | Floor bit 0 (for debugging) |
| `floor[1]` | **PIN_N1** | LEDR[5] | Floor bit 1 (for debugging) |
| `floor[2]` | **PIN_U2** | LEDR[6] | Floor bit 2 (for debugging) |
| `floor[3]` | **PIN_U1** | LEDR[7] | Floor bit 3 (for debugging) |

---

## Quartus Step-by-Step Instructions

### Step 1: Create New Quartus Project

1. **Launch Quartus Prime**
   - Open Quartus Prime software

2. **Create New Project**
   - Go to: `File` → `New Project Wizard`
   - Click `Next` on the introduction page

3. **Set Project Directory and Name**
   - **Directory**: Browse to your HW3 folder
     ```
     /Users/elshazlio/Library/CloudStorage/OneDrive-Personal/Documents/Library/ASIC/HW3
     ```
   - **Project Name**: `elevator_fpga`
   - **Top-Level Design Entity**: `elevator_top`
   - Click `Next`

4. **Project Type**
   - Select: `Empty project`
   - Click `Next`

5. **Add Design Files**
   - Click `Add...` button
   - Navigate to your HW3 folder and select:
     - `elevator_top.sv`
     - `request_resolver.sv`
     - `unit_control.sv`
     - `ssd.sv`
   - Make sure all 4 files are listed
   - Click `Next`

6. **Family, Device & Board Settings**
   - **Family**: Select `Cyclone V`
   - **Device**: 
     - In the device list, filter by:
       - Package: `F484`
       - Pin count: `484`
     - Select: **`5CEBA4F23C7`**
   - Click `Next`

7. **EDA Tool Settings**
   - Leave default (None)
   - Click `Next`

8. **Summary**
   - Review your settings
   - Click `Finish`

---

### Step 2: Verify Design Files

1. **Open Project Navigator**
   - On the left side, expand `Files` tab
   - You should see all 4 `.sv` files listed

2. **Set Top-Level Entity**
   - Right-click on `elevator_top.sv`
   - Select `Set as Top-Level Entity`
   - The file icon should change to show it's the top level

---

### Step 3: Create Constraints File (SDC)

1. **Create Timing Constraints**
   - Go to: `File` → `New...`
   - Select `Synopsys Design Constraints File`
   - Click `OK`

2. **Add Clock Constraint**
   - Copy and paste this content:

   ```tcl
   # Clock constraint for 50 MHz input clock
   create_clock -name clk -period 20.000 [get_ports {clk}]
   
   # Derive PLL clocks (if any)
   derive_pll_clocks
   
   # Derive clock uncertainty
   derive_clock_uncertainty
   
   # Set input delays (2ns setup time)
   set_input_delay -clock clk -max 2 [all_inputs]
   set_input_delay -clock clk -min 0 [all_inputs]
   
   # Set output delays (2ns)
   set_output_delay -clock clk -max 2 [all_outputs]
   set_output_delay -clock clk -min 0 [all_outputs]
   ```

3. **Save the File**
   - Save as: `elevator_fpga.sdc` in your project folder
   - Go to: `Assignments` → `Settings`
   - Select `Timing Analyzer` under `Category`
   - Click `...` next to `Settings File Name`
   - Select your `elevator_fpga.sdc` file
   - Click `OK`

---

### Step 4: Assign Pins

You have **three methods** to assign pins. Choose the one you're most comfortable with:

#### Method A: Using Pin Planner (GUI - Recommended for Beginners)

1. **Open Pin Planner**
   - Go to: `Assignments` → `Pin Planner`
   - Or press `Ctrl+Shift+N`

2. **Assign Pins in the Table**
   - In the bottom pane, you'll see a table with columns: `Node Name`, `Direction`, `Location`, etc.
   - Find each signal and assign its location:

   **Clock and Reset:**
   ```
   Node Name: clk          → Location: PIN_M9
   Node Name: reset_n      → Location: PIN_U7
   ```

   **Inside Buttons (Switches):**
   ```
   Node Name: inside_buttons[0]  → Location: PIN_U13
   Node Name: inside_buttons[1]  → Location: PIN_V13
   Node Name: inside_buttons[2]  → Location: PIN_T13
   Node Name: inside_buttons[3]  → Location: PIN_T12
   Node Name: inside_buttons[4]  → Location: PIN_AA15
   Node Name: inside_buttons[5]  → Location: PIN_AB15
   Node Name: inside_buttons[6]  → Location: PIN_AA14
   Node Name: inside_buttons[7]  → Location: PIN_AA13
   Node Name: inside_buttons[8]  → Location: PIN_AB13
   Node Name: inside_buttons[9]  → Location: PIN_AB12
   ```

   **Status LEDs:**
   ```
   Node Name: mv_up        → Location: PIN_AA2
   Node Name: mv_down      → Location: PIN_AA1
   Node Name: door_open    → Location: PIN_W2
   ```

   **Seven-Segment Display (HEX0):**
   ```
   Node Name: ssd_hex[0]   → Location: PIN_U21
   Node Name: ssd_hex[1]   → Location: PIN_V21
   Node Name: ssd_hex[2]   → Location: PIN_W22
   Node Name: ssd_hex[3]   → Location: PIN_W21
   Node Name: ssd_hex[4]   → Location: PIN_Y22
   Node Name: ssd_hex[5]   → Location: PIN_Y21
   Node Name: ssd_hex[6]   → Location: PIN_AA22
   ```

3. **Close Pin Planner**
   - File → Close Pin Planner
   - It will automatically save assignments

#### Method B: Using Assignment Editor

1. **Open Assignment Editor**
   - Go to: `Assignments` → `Assignment Editor`

2. **Add New Assignments**
   - Double-click in the `<< new >>` row
   - Category: `Pin`
   - To: Select signal name from dropdown
   - Assignment Name: `Location`
   - Value: Enter pin (e.g., `PIN_M9`)
   - Click elsewhere to save the row
   - Repeat for all signals

#### Method C: Using TCL Script (Fastest)

1. **Open TCL Console**
   - Go to: `View` → `Utility Windows` → `Tcl Console`
   - The console appears at the bottom

2. **Copy and Paste All Pin Assignments**
   - Copy this entire block and paste into the Tcl Console:

   ```tcl
   # Clock and Reset
   set_location_assignment PIN_M9 -to clk
   set_location_assignment PIN_U7 -to reset_n
   
   # Inside Buttons (Slide Switches SW0-SW9)
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
   
   # Status LEDs (LEDR0-LEDR2)
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
   
   # Set I/O standards (3.3V LVTTL for DE0-CV)
   set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk
   set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to reset_n
   set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to inside_buttons[*]
   set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to mv_up
   set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to mv_down
   set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to door_open
   set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ssd_hex[*]
   ```

3. **Verify Assignments**
   - Go to: `Assignments` → `Pin Planner` to verify all pins are assigned

---

### Step 5: Handle Unused Inputs

Since we're not using `up_buttons` and `dn_buttons`, we need to tie them to ground (logic 0).

**Option 1: Modify Top-Level File (Recommended)**

Create a wrapper module that ties unused inputs to 0:

1. Create new file: `File` → `New` → `SystemVerilog HDL File`
2. Name it: `elevator_top_fpga.sv`
3. Add this code:

```systemverilog
//******************************************************************************
// File: elevator_top_fpga.sv
// FPGA Wrapper for Elevator Controller
// Ties unused up_buttons and dn_buttons to ground
//******************************************************************************

module elevator_top_fpga (
    // System inputs
    input  logic        clk,
    input  logic        reset_n,
    
    // Button inputs (only inside buttons for FPGA demo)
    input  logic [9:0]  inside_buttons,
    
    // Status outputs
    output logic        mv_up,
    output logic        mv_down,
    output logic        door_open,
    
    // Seven-segment display output
    output logic [6:0]  ssd_hex
);

    // Unused signals tied to ground
    logic [8:0] up_buttons_unused;
    logic [8:0] dn_buttons_unused;
    logic [3:0] floor_unused;  // floor output used internally only
    
    assign up_buttons_unused = 9'b0;
    assign dn_buttons_unused = 9'b0;
    
    // Instantiate the actual elevator controller
    elevator_top #(
        .NUM_FLOORS(10),
        .MOVE_TIME(2),
        .DOOR_TIME(2),
        .CLK_FREQ(50_000_000)
    ) u_elevator_top (
        .clk(clk),
        .reset_n(reset_n),
        .inside_buttons(inside_buttons),
        .up_buttons(up_buttons_unused),
        .dn_buttons(dn_buttons_unused),
        .floor(floor_unused),
        .mv_up(mv_up),
        .mv_down(mv_down),
        .door_open(door_open),
        .ssd_hex(ssd_hex)
    );

endmodule
```

4. **Set as Top-Level**:
   - Right-click `elevator_top_fpga.sv`
   - Select `Set as Top-Level Entity`

**Option 2: Use Quartus Settings**

If you keep `elevator_top` as top-level, Quartus will automatically tie unconnected inputs to ground with a warning. This is acceptable for testing.

---

### Step 6: Compile the Design

1. **Start Compilation**
   - Click the `Start Compilation` button (purple play icon)
   - Or go to: `Processing` → `Start Compilation`
   - Or press `Ctrl+L`

2. **Wait for Compilation**
   - This takes 2-5 minutes depending on your PC
   - Watch the progress in the `Tasks` pane

3. **Check for Errors**
   - **Green checkmark** = Success! ✓
   - **Red X** = Errors - check the Messages pane
   - **Yellow warning** = Warnings (usually OK, but review them)

4. **Review Compilation Report**
   - Double-click `Compilation Report` in the Tasks pane
   - Check these sections:
     - **Flow Summary**: Verify logic utilization
     - **Fitter → Resource Section**: Should use < 5% of device
     - **TimeQuest Timing Analyzer**: Verify timing is met

---

### Step 7: Timing Analysis

1. **Open TimeQuest Timing Analyzer**
   - Go to: `Tools` → `TimeQuest Timing Analyzer`

2. **Create Timing Netlist**
   - Click `Create Timing Netlist` button
   - Select: `Post-Fit` analysis
   - Click `OK`

3. **Read SDC File**
   - The constraints from your `.sdc` file are automatically loaded

4. **Update Timing Netlist**
   - Click `Update Timing Netlist`

5. **Report Timing**
   - Double-click `Reports` → `Custom Reports` → `Report Timing`
   - Check that **Slack** is positive (green)
   - If slack is negative (red), timing violations exist

6. **Check Summary**
   - Look at Setup/Hold slack
   - Both should be positive (> 0 ns)

---

### Step 8: Program the FPGA

1. **Connect FPGA Board**
   - Connect DE0-CV board to PC via USB Blaster cable
   - Power on the board

2. **Open Programmer**
   - Go to: `Tools` → `Programmer`
   - Or click the `Programmer` icon

3. **Setup Hardware**
   - Click `Hardware Setup...`
   - Select `USB-Blaster [USB-0]` from the list
   - Click `Close`

4. **Add Programming File**
   - If not already loaded, click `Add File...`
   - Navigate to: `output_files/elevator_fpga.sof` (or your project name)
   - Make sure `.sof` file is selected (for RAM programming)
   - Check the `Program/Configure` checkbox

5. **Program the Device**
   - Click `Start` button
   - Progress bar shows programming status
   - **Success** message appears when done (100%)

6. **Verify Programming**
   - The FPGA is now programmed!
   - HEX0 should display `0` (ground floor)

> **Note**: `.sof` file is volatile (RAM) - it's erased when power is removed. To permanently program the FPGA, use `.pof` or `.jic` files for configuration device programming.

---

## Testing on Hardware

### Initial Power-Up Test

1. **Check Default State**
   - HEX0 should show: `0` (ground floor)
   - All LEDs should be OFF
   - All switches should be DOWN

2. **Test Reset**
   - Press and release **KEY[0]** (reset button)
   - HEX0 should remain at `0`
   - LEDs should remain OFF

### Basic Movement Test

1. **Request Floor 3**
   - Flip **SW[3]** UP
   - Wait ~1 second
   - **LEDR[0]** (mv_up) should turn ON
   - HEX0 should start counting: `0 → 1 → 2 → 3`
   - Each floor takes ~2 seconds
   - When reaching floor 3:
     - LEDR[0] turns OFF
     - **LEDR[2]** (door_open) turns ON
     - Display shows `3`
   - After ~2 seconds, LEDR[2] turns OFF
   - Flip SW[3] DOWN

2. **Request Floor 0 (Return to Ground)**
   - Flip **SW[0]** UP
   - **LEDR[1]** (mv_down) should turn ON
   - HEX0 counts down: `3 → 2 → 1 → 0`
   - At floor 0:
     - LEDR[1] turns OFF
     - LEDR[2] (door_open) turns ON
     - Display shows `0`
   - Flip SW[0] DOWN

### Multiple Request Test

1. **From Floor 0, Request Floors 2, 5, 8**
   - Flip UP: SW[2], SW[5], SW[8]
   - LEDR[0] turns ON (moving up)
   - Elevator should visit in order: `2 → 5 → 8`
   - At each floor:
     - Movement stops
     - Door opens (LEDR[2] ON)
     - After 2 seconds, continues to next floor
   - Flip DOWN each switch as floors are reached

### Direction Persistence Test

1. **From Floor 5, Request Floors 3 and 7**
   - First, go to floor 5 (flip SW[5])
   - Once at floor 5, flip UP: SW[3] and SW[7]
   - Elevator should go UP first to floor 7
   - Then come back DOWN to floor 3
   - This demonstrates proper direction persistence

### Edge Case Tests

1. **Same Floor Request**
   - When at floor N, flip SW[N] UP
   - Door should open immediately (LEDR[2] ON)
   - No movement LEDs should light

2. **Multiple Simultaneous Requests**
   - Flip several switches at once
   - Elevator should service them in logical order
   - Up requests first (ascending), then down requests (descending)

---

## Expected Behavior Summary

| Scenario | Expected Result |
|----------|----------------|
| **Power On** | HEX0 = 0, all LEDs OFF |
| **Reset (KEY[0])** | Return to floor 0, clear all states |
| **Request Higher Floor** | LEDR[0] ON, HEX0 counts up, ~2s per floor |
| **Request Lower Floor** | LEDR[1] ON, HEX0 counts down, ~2s per floor |
| **Reach Target Floor** | Movement LED OFF, LEDR[2] ON for ~2s |
| **Same Floor Request** | LEDR[2] ON immediately, no movement |
| **Multiple Requests (Up)** | Services floors in ascending order |
| **Multiple Requests (Down)** | Services floors in descending order |
| **Direction Persistence** | Completes all requests in current direction first |

---

## Troubleshooting

### Compilation Issues

| Problem | Solution |
|---------|----------|
| **"Error: Can't find file"** | Verify all 4 `.sv` files are in project directory |
| **"Error: Unknown module"** | Check module names match filenames |
| **"Warning: Pins unassigned"** | Complete Step 4 (Pin Assignment) |
| **Timing violations** | Usually OK for this design, but check TimeQuest report |

### Programming Issues

| Problem | Solution |
|---------|----------|
| **"No hardware detected"** | Check USB cable, install USB Blaster driver |
| **"Programming failed"** | Power cycle board, try programming again |
| **Can't find .sof file** | Run full compilation first (Step 6) |

### Hardware Testing Issues

| Problem | Possible Cause | Solution |
|---------|---------------|----------|
| **HEX0 shows nothing** | SSD decoder issue | Check `ssd.sv` is included and correct |
| **HEX0 shows wrong number** | Pin assignment error | Verify HEX0 pins in Pin Planner |
| **No LED response** | Pin assignment error | Verify LEDR pins in Pin Planner |
| **Elevator doesn't move** | Clock/reset issue | Check PIN_M9 (clock), press KEY[0] (reset) |
| **Movement too fast/slow** | Clock divider issue | Verify CLK_FREQ parameter = 50_000_000 |
| **Switch has no effect** | Pin assignment error | Verify SW pins match `inside_buttons` in Pin Planner |
| **Erratic behavior** | Multiple issues | Reset (KEY[0]), turn all switches DOWN, try again |

### Debug Tips

1. **Use SignalTap Logic Analyzer**
   - Go to: `Tools` → `SignalTap Logic Analyzer`
   - Add internal signals to monitor behavior
   - Trigger on specific conditions

2. **Check Pin Assignments**
   - `Assignments` → `Pin Planner`
   - Verify every signal has a location

3. **Review Compilation Report**
   - Check logic utilization (should be < 5%)
   - Look for warnings about unused or unconnected signals

4. **Simplify Test**
   - Test with single floor request first
   - Gradually add complexity

---

## Advanced: Programming Configuration Device

To make the design **persistent** across power cycles:

1. **Convert to .jic File**
   - Go to: `File` → `Convert Programming Files`
   - Programming file type: `JTAG Indirect Configuration File (.jic)`
   - Configuration device: `EPCQ16` (for DE0-CV)
   - Add `.sof` file as input
   - Generate `.jic` file

2. **Program Configuration Device**
   - In Programmer, change mode to `Active Serial Programming`
   - Add `.jic` file
   - Check `Program/Configure` and `Verify`
   - Click `Start`

Now the design will persist even after power-off!

---

## Pin Assignment Summary Table (Copy-Paste Format)

```
# For Quartus TCL Console or .qsf file

set_location_assignment PIN_M9 -to clk
set_location_assignment PIN_U7 -to reset_n
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
set_location_assignment PIN_AA2 -to mv_up
set_location_assignment PIN_AA1 -to mv_down
set_location_assignment PIN_W2 -to door_open
set_location_assignment PIN_U21 -to ssd_hex[0]
set_location_assignment PIN_V21 -to ssd_hex[1]
set_location_assignment PIN_W22 -to ssd_hex[2]
set_location_assignment PIN_W21 -to ssd_hex[3]
set_location_assignment PIN_Y22 -to ssd_hex[4]
set_location_assignment PIN_Y21 -to ssd_hex[5]
set_location_assignment PIN_AA22 -to ssd_hex[6]
```

---

## Quick Reference Card

### DE0-CV Board Layout

```
┌─────────────────────────────────────────┐
│  DE0-CV FPGA Board                      │
│                                         │
│  [SW9]...[SW0]  ← Inside Buttons        │
│                                         │
│  [LEDR9]...[LEDR0]  ← Status LEDs       │
│   (Use LEDR2,1,0)                       │
│                                         │
│  [HEX5]...[HEX0]  ← Seven Segment       │
│   (Use HEX0)                            │
│                                         │
│  [KEY3]...[KEY0]  ← Buttons             │
│   (Use KEY0 for Reset)                  │
│                                         │
│  [USB Blaster] ← Programming Port       │
└─────────────────────────────────────────┘
```

### Control Mapping

| Control | Action |
|---------|--------|
| **KEY[0]** | Reset elevator to floor 0 |
| **SW[0]** | Request floor 0 (ground) |
| **SW[1]** | Request floor 1 |
| **SW[2]** | Request floor 2 |
| **SW[3]** | Request floor 3 |
| **SW[4]** | Request floor 4 |
| **SW[5]** | Request floor 5 |
| **SW[6]** | Request floor 6 |
| **SW[7]** | Request floor 7 |
| **SW[8]** | Request floor 8 |
| **SW[9]** | Request floor 9 (top) |

### Status Indicators

| LED | Meaning |
|-----|---------|
| **LEDR[0]** | Moving UP |
| **LEDR[1]** | Moving DOWN |
| **LEDR[2]** | Door OPEN |
| **HEX0** | Current Floor (0-9) |

---

## Conclusion

You now have a complete guide to implement your elevator controller on the DE0-CV FPGA board! Follow the steps carefully, and you should see your simulated design running on real hardware.

**Remember:**
- Start with simple tests (single floor requests)
- Verify each function before moving to complex scenarios
- Use the troubleshooting section if issues arise
- The design has been verified in simulation, so hardware issues are typically pin-related

**Good luck with your FPGA implementation!** 🚀

---

**Document Version**: 1.0  
**Last Updated**: November 14, 2025  
**Author**: AI Assistant  
**Course**: ECNG410401 ASIC Design Using CAD

