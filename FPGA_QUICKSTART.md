# FPGA Quick Start Guide - Elevator Controller

## 🚀 Fast Track to Hardware Implementation

This is a condensed version of the full implementation guide. For detailed explanations, see `FPGA_IMPLEMENTATION_GUIDE.md`.

---

## Prerequisites

✅ Quartus Prime installed  
✅ DE0-CV FPGA board  
✅ USB Blaster cable  
✅ All simulation tests passed  

---

## 5-Minute Setup

### 1. Create Quartus Project (2 min)

```
File → New Project Wizard
  Directory: <Your HW3 folder>
  Name: elevator_fpga
  Top-Level: elevator_top_fpga
  Device: Cyclone V → 5CEBA4F23C7
  
Add Files:
  ✓ elevator_top_fpga.sv (USE THIS as top-level)
  ✓ elevator_top.sv
  ✓ request_resolver.sv
  ✓ unit_control.sv
  ✓ ssd.sv
```

### 2. Assign Pins (1 min)

Open Tcl Console: `View → Utility Windows → Tcl Console`

**Copy-paste this entire block:**

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

# I/O Standards
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to *
```

### 3. Compile (2-5 min)

```
Processing → Start Compilation
```

Wait for green checkmark ✓

### 4. Program FPGA (30 sec)

```
Tools → Programmer
  Hardware Setup → Select USB-Blaster
  Add File → output_files/elevator_fpga.sof
  ✓ Program/Configure checkbox
  Click START
```

---

## Testing (2 minutes)

### Test 1: Basic Movement
```
1. All switches DOWN
2. Flip SW[3] UP → Elevator moves to floor 3
   Expected: LEDR[0] ON (moving up), HEX0 shows 0→1→2→3
   At floor 3: LEDR[2] ON (door open)
3. Flip SW[3] DOWN
```

### Test 2: Multiple Floors
```
1. From floor 0, flip UP: SW[2], SW[5], SW[8]
2. Elevator visits: 2 → 5 → 8 (in order)
3. Door opens at each floor
4. Flip DOWN each switch as reached
```

### Test 3: Direction Persistence
```
1. Go to floor 5 (SW[5])
2. At floor 5, flip UP: SW[3] and SW[7]
3. Elevator goes UP to 7 first, then DOWN to 3
```

---

## Control Reference

| Input | Function |
|-------|----------|
| **KEY[0]** | Reset (goes to floor 0) |
| **SW[0-9]** | Request floor 0-9 |

| Output | Meaning |
|--------|---------|
| **LEDR[0]** | Moving UP |
| **LEDR[1]** | Moving DOWN |
| **LEDR[2]** | Door OPEN |
| **HEX0** | Current floor (0-9) |

---

## Timing

- **Per floor**: ~2 seconds
- **Door open**: ~2 seconds
- **Floor 0 → 9**: ~18 seconds

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| HEX0 blank | Check pin assignments for ssd_hex[6:0] |
| No LED response | Check pin assignments for LEDR |
| Compilation error | Verify all 5 .sv files are added |
| Can't program | Check USB cable, install drivers |
| Wrong behavior | Press KEY[0] to reset, try again |

---

## Board Layout

```
DE0-CV Top View:
┌─────────────────────────────────┐
│ [SW9][SW8]...[SW1][SW0]  ← Use │
│                                 │
│ [●]...[●][●][●]  ← LEDR 2,1,0  │
│                                 │
│ [HEX5]...[HEX1][HEX0]  ← Use    │
│                                 │
│ [KEY3][KEY2][KEY1][KEY0] ← Use  │
└─────────────────────────────────┘
```

---

## Success Checklist

✅ Compilation passes (green checkmark)  
✅ Programming successful (100%)  
✅ HEX0 shows "0" on power-up  
✅ LEDR[0] lights when moving up  
✅ LEDR[1] lights when moving down  
✅ LEDR[2] lights when door opens  
✅ Elevator responds to SW requests  
✅ Takes ~2 seconds per floor  

---

## Need More Help?

See the full guide: **`FPGA_IMPLEMENTATION_GUIDE.md`**

- Detailed Quartus screenshots
- Pin Planner instructions
- TimeQuest timing analysis
- Advanced debugging tips
- SignalTap setup
- Configuration device programming

---

**Ready to go? Start with Step 1 above!** 🎯


