# Elevator FPGA Debugging Guide

## Issue: Switches Don't Respond

You've programmed the FPGA, HEX0 shows "0", but switches don't do anything.

---

## Quick Diagnostic Steps

### Step 1: Check Reset Button
**Problem**: System might be stuck in reset.

**Test**:
1. Make sure KEY[0] is **NOT pressed** (it should be in the "up" position)
2. The reset is **active-low**: 
   - Released (up) = HIGH = Normal operation ✓
   - Pressed (down) = LOW = Reset state ✗

**If KEY[0] was pressed**: Release it and try your switches again.

---

### Step 2: Understand the Timing
**Problem**: Response delay might make it seem like nothing is happening.

**How the system works**:
1. You flip SW[3] UP
2. System waits ~1 second (clock divider counting)
3. **THEN** LEDR[0] turns ON and elevator starts moving
4. Each floor takes ~2 seconds

**Test**:
1. Flip SW[5] UP (request floor 5)
2. **Wait 5-10 seconds without touching anything**
3. Watch HEX0 and LEDR[0] - it should start moving after ~1 second

**Expected timeline**:
- t=0s: Flip SW[5] UP
- t=1s: LEDR[0] (mv_up) turns ON, HEX0 shows "0"
- t=3s: HEX0 shows "1"
- t=5s: HEX0 shows "2"
- t=7s: HEX0 shows "3"
- t=9s: HEX0 shows "4"
- t=11s: HEX0 shows "5", LEDR[0] turns OFF, LEDR[2] (door) turns ON
- t=13s: LEDR[2] turns OFF, done

---

### Step 3: Verify Switch Connections
**Use the simple switch test to verify hardware**:

1. In Quartus, set `switch_test.sv` as the top-level entity:
   - Right-click `switch_test.sv`
   - Select "Set as Top-Level Entity"

2. Use the **SAME pin assignments** (don't change them)

3. Recompile and reprogram

4. Test:
   - Flip SW[0] UP → LEDR[0] should turn ON immediately
   - Flip SW[1] UP → LEDR[1] should turn ON immediately
   - Flip SW[2] UP → LEDR[2] should turn ON immediately
   - HEX0 should show "8" when any switch is UP

If this works, your switches are fine. If not, check pin assignments.

---

### Step 4: Use Debug Version
**See internal signals to diagnose the issue**:

1. Set `elevator_top_fpga_debug.sv` as the top-level entity

2. Add these additional LED pin assignments in Pin Planner:
   ```
   debug_control_enable → PIN_N2 (LEDR[3])
   debug_req_valid      → PIN_N1 (LEDR[4])
   debug_switch_test    → PIN_U2 (LEDR[5])
   debug_any_switch     → PIN_U1 (LEDR[6])
   debug_reset_status   → PIN_W1 (LEDR[7])
   ```

3. Recompile and reprogram

4. Observe the LEDs:
   - **LEDR[7]**: Should be ON (reset_n is HIGH)
     - If OFF: Reset is stuck, check KEY[0] pin assignment
   - **LEDR[6]**: Should turn ON when ANY switch is flipped UP
     - If OFF: Switches not reading correctly
   - **LEDR[3]**: Should blink briefly every 1 second
     - If not blinking: Clock divider issue
   - **LEDR[4]**: Should turn ON when you flip a switch
     - If OFF: Request resolver isn't detecting requests

---

## Most Common Issues

### Issue 1: "I'm too impatient"
**Symptom**: I flip the switch and nothing happens!

**Solution**: Wait 10 seconds. The first response takes ~1 second due to clock divider, then each floor takes ~2 seconds.

---

### Issue 2: "Reset button is pressed"
**Symptom**: Nothing works, HEX0 stuck at "0"

**Solution**: 
- Make sure KEY[0] is in the UP (released) position
- KEY[0] is active-low: down=reset, up=normal

---

### Issue 3: "Wrong pin assignment"
**Symptom**: Switches don't read at all

**Solution**: 
1. Open Pin Planner in Quartus
2. Verify these assignments:
   ```
   reset_n → PIN_U7 (KEY[0])
   inside_buttons[0] → PIN_U13 (SW[0])
   inside_buttons[1] → PIN_V13 (SW[1])
   inside_buttons[2] → PIN_T13 (SW[2])
   inside_buttons[3] → PIN_T12 (SW[3])
   inside_buttons[4] → PIN_AA15 (SW[4])
   inside_buttons[5] → PIN_AB15 (SW[5])
   inside_buttons[6] → PIN_AA14 (SW[6])
   inside_buttons[7] → PIN_AA13 (SW[7])
   inside_buttons[8] → PIN_AB13 (SW[8])
   inside_buttons[9] → PIN_AB12 (SW[9])
   ```

---

### Issue 4: "I forgot to set I/O standard"
**Symptom**: Erratic or no behavior

**Solution**: 
In Quartus TCL Console, run:
```tcl
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to reset_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to inside_buttons[*]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to mv_up
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to mv_down
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to door_open
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ssd_hex[*]
```
Then recompile.

---

## Recommended Debugging Sequence

1. **First**: Make sure KEY[0] is released (up position)
2. **Second**: Flip SW[5] UP and WAIT 15 seconds without touching anything
3. **Third**: If nothing happened, use `switch_test.sv` to verify hardware
4. **Fourth**: If switches work in test, use `elevator_top_fpga_debug.sv` to see internal signals
5. **Fifth**: Check Pin Planner assignments match exactly
6. **Sixth**: Verify I/O standards are set to 3.3-V LVTTL

---

## Expected Working Behavior

**Test 1: Request Floor 3**
```
Time    Action                          LEDs              HEX0
----    ------                          ----              ----
0s      Flip SW[3] UP                  [---]             0
1s      (wait for clock divider)       [↑--]             0
3s      (moving to floor 1)            [↑--]             1
5s      (moving to floor 2)            [↑--]             2
7s      (reaching floor 3)             [--D]             3
9s      (door closing)                 [---]             3
```

Legend: ↑=mv_up, ↓=mv_down, D=door_open, -=off

**Test 2: Return to Floor 0**
```
Time    Action                          LEDs              HEX0
----    ------                          ----              ----
0s      Flip SW[0] UP                  [---]             3
1s      (wait for clock divider)       [-↓-]             3
3s      (moving to floor 2)            [-↓-]             2
5s      (moving to floor 1)            [-↓-]             1
7s      (reaching floor 0)             [--D]             0
9s      (door closing)                 [---]             0
```

---

## Still Not Working?

Check the Quartus Messages pane for:
- Warnings about unconstrained paths
- Errors about timing violations
- Warnings about unused pins

Review the Compilation Report:
- Fitter → Resource Section → Should use < 5% of device
- TimeQuest → All slack values should be positive

If you see timing violations (negative slack), the design might not work reliably at 50 MHz.

---

## Contact Info

If none of these steps work, provide:
1. Screenshot of Pin Planner showing all assignments
2. Screenshot of Compilation Report showing any errors/warnings
3. Description of exact behavior (do any LEDs ever light?)
4. Result of switch_test.sv (do LEDs light when switches flip?)

