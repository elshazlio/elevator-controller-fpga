# 🚀 FPGA Implementation Cheat Sheet - Elevator Controller

**Print this page and keep it handy while working!**

---

## 📋 QUICK SETUP

### 1️⃣ Quartus Project (2 min)
```
File → New Project Wizard
  Name: elevator_fpga
  Device: 5CEBA4F23C7
  Top-Level: elevator_top_fpga
  
Add Files: (5 files)
  ✓ elevator_top_fpga.sv (wrapper - USE AS TOP)
  ✓ elevator_top.sv
  ✓ request_resolver.sv
  ✓ unit_control.sv
  ✓ ssd.sv
```

### 2️⃣ Pin Assignment (1 min)
```
View → Utility Windows → Tcl Console
Copy-paste the pin script from FPGA_QUICKSTART.md
```

### 3️⃣ Compile (2-5 min)
```
Processing → Start Compilation
Wait for green ✓
```

### 4️⃣ Program (30 sec)
```
Tools → Programmer
Hardware Setup → USB-Blaster
Add File → output_files/elevator_fpga.sof
✓ Program/Configure
Click START
```

---

## 📌 PIN QUICK REFERENCE

### Essential Pins (Must Know)
| Signal | Pin | Component |
|--------|-----|-----------|
| **clk** | **M9** | CLOCK_50 |
| **reset_n** | **U7** | KEY[0] |

### Switches (Inside Buttons)
| SW[0] | SW[1] | SW[2] | SW[3] | SW[4] | SW[5] | SW[6] | SW[7] | SW[8] | SW[9] |
|-------|-------|-------|-------|-------|-------|-------|-------|-------|-------|
| U13 | V13 | T13 | T12 | AA15 | AB15 | AA14 | AA13 | AB13 | AB12 |

### LEDs (Status)
| LEDR[0] (mv_up) | LEDR[1] (mv_down) | LEDR[2] (door_open) |
|-----------------|-------------------|---------------------|
| AA2 | AA1 | W2 |

### HEX0 (Floor Display)
| [0] | [1] | [2] | [3] | [4] | [5] | [6] |
|-----|-----|-----|-----|-----|-----|-----|
| U21 | V21 | W22 | W21 | Y22 | Y21 | AA22 |

---

## 🎮 BOARD LAYOUT

```
┌──────────────────────────────────────┐
│  [SW9][SW8][SW7][SW6][SW5][SW4]     │  ← Floors 9,8,7,6,5,4
│  [SW3][SW2][SW1][SW0]                │  ← Floors 3,2,1,0
│                                      │
│  [●][●][●]  ← LEDR 2,1,0            │  ← door,down,up
│                                      │
│  [HEX0] ← Shows floor               │  ← Current floor
│                                      │
│  [KEY0] ← RESET                     │  ← Press to reset
└──────────────────────────────────────┘
```

---

## 🧪 TESTING CHECKLIST

### ✅ Power-Up Test
- [ ] HEX0 shows "0"
- [ ] All LEDs OFF
- [ ] All switches DOWN

### ✅ Single Floor Test
- [ ] SW[3] UP → LEDR[0] ON, HEX0: 0→1→2→3
- [ ] At floor 3 → LEDR[2] ON (door)
- [ ] Door closes → All LEDs OFF
- [ ] SW[3] DOWN

### ✅ Multiple Floors Test
- [ ] SW[2], SW[5], SW[8] UP
- [ ] Visits: 2 → 5 → 8
- [ ] Door opens at each

### ✅ Reset Test
- [ ] Press KEY[0]
- [ ] Returns to floor 0

---

## ⚡ EXPECTED TIMING

| Event | Time |
|-------|------|
| Floor-to-floor | ~2 seconds |
| Door open | ~2 seconds |
| Floor 0 → 9 | ~18 seconds |

---

## 🔧 TROUBLESHOOTING QUICK FIX

| Problem | Quick Fix |
|---------|-----------|
| HEX0 blank | Check HEX0 pins (U21-AA22) |
| No LEDs | Check LEDR pins (AA2,AA1,W2) |
| No response | Press KEY[0], check SW pins |
| Won't program | Check USB, power cycle |
| Weird behavior | Reset, turn all SW DOWN |

---

## 💡 TCL PIN SCRIPT (Copy-Paste)

```tcl
# Clock & Reset
set_location_assignment PIN_M9 -to clk
set_location_assignment PIN_U7 -to reset_n

# Switches (Inside Buttons)
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

# LEDs
set_location_assignment PIN_AA2 -to mv_up
set_location_assignment PIN_AA1 -to mv_down
set_location_assignment PIN_W2 -to door_open

# HEX0
set_location_assignment PIN_U21 -to ssd_hex[0]
set_location_assignment PIN_V21 -to ssd_hex[1]
set_location_assignment PIN_W22 -to ssd_hex[2]
set_location_assignment PIN_W21 -to ssd_hex[3]
set_location_assignment PIN_Y22 -to ssd_hex[4]
set_location_assignment PIN_Y21 -to ssd_hex[5]
set_location_assignment PIN_AA22 -to ssd_hex[6]

# I/O Standard
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to *
```

---

## 📊 LED MEANING

| LED | When ON | Meaning |
|-----|---------|---------|
| LEDR[0] | Moving UP | ⬆️ Elevator going higher |
| LEDR[1] | Moving DOWN | ⬇️ Elevator going lower |
| LEDR[2] | At target floor | 🚪 Door is OPEN |
| HEX0 | Always | Current floor (0-9) |

---

## 🎯 SUCCESS CHECKLIST

- [ ] Compilation passes (green ✓)
- [ ] Timing positive (slack > 0)
- [ ] Programming successful (100%)
- [ ] HEX0 shows "0" at power-up
- [ ] KEY[0] resets to floor 0
- [ ] All 10 switches work
- [ ] LEDR[0] lights going up
- [ ] LEDR[1] lights going down
- [ ] LEDR[2] lights at target
- [ ] ~2 sec per floor
- [ ] ~2 sec door open

---

## 🆘 EMERGENCY RESET

**If anything goes wrong:**

1. Press **KEY[0]** (reset)
2. Turn **ALL switches DOWN**
3. Wait for HEX0 = "0"
4. Try again

---

## 📞 WHEN STUCK

1. Check **Messages** pane in Quartus
2. Verify **Pin Planner** assignments
3. Read **Compilation Report**
4. Check **TimeQuest** timing
5. See full guides for details

---

## 🎓 DEVICE INFO

```
Board:    DE0-CV
FPGA:     Cyclone V
Device:   5CEBA4F23C7
Package:  F484 (484 pins)
Clock:    50 MHz (PIN_M9)
```

---

## 📁 FILES NEEDED

```
elevator_top_fpga.sv  ← Top-level (FPGA wrapper)
elevator_top.sv       ← Main controller
request_resolver.sv   ← Priority logic
unit_control.sv       ← FSM
ssd.sv               ← Display decoder
```

---

## ⏱️ TYPICAL WORKFLOW

```
Create Project    → 2 min
Assign Pins       → 1 min
Compile           → 3 min
Program           → 30 sec
Test              → 2 min
─────────────────────────
TOTAL             ~ 9 min
```

---

**Print this page • Keep handy • Refer often**

**Good luck! 🚀**

---

_Elevator Controller • HW3 • ECNG410401 • Nov 2025_


