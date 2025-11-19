# QuestaSim Setup Guide

## Files You Need

Copy these files to your Windows VM folder:
- `ssd.sv`
- `request_resolver.sv`
- `unit_control.sv`
- `elevator_top.sv`
- `elevator_top_tb.sv`
- `run.do` ← the script

## How to Run

### Method 1: Using the .do Script (Recommended)

1. **Open QuestaSim**

2. **Change to your project directory:**
   ```tcl
   cd "C:/path/to/your/project/folder"
   ```
   Replace with your actual path, e.g., `cd "C:/Users/YourName/Documents/HW3"`

3. **Run the script:**
   ```tcl
   do run.do
   ```

4. **Done!** The simulation will:
   - Compile all files
   - Run the testbench
   - Show waveforms
   - Print results in the Transcript window

### Method 2: If Script Fails (Manual)

If the script doesn't work, run these commands one by one:

```tcl
# Change to your directory
cd "C:/path/to/your/project"

# Create library
vlib work

# Compile files
vlog -sv ssd.sv
vlog -sv request_resolver.sv
vlog -sv unit_control.sv
vlog -sv elevator_top.sv
vlog -sv elevator_top_tb.sv

# Start simulation
vsim work.elevator_top_tb

# Add waves
add wave *

# Run
run -all

# Zoom to see all
wave zoom full
```

## Path-Agnostic Notes

✅ **The script IS path-agnostic** - it uses relative paths. As long as:
- All `.sv` files are in the same folder
- `run.do` is in that same folder
- You `cd` to that folder before running `do run.do`

Then it will work on any machine, any path.

## What You'll See

### Transcript Window (Text Output)
```
========================================
Elevator Controller Testbench
Simulation Start Time: 0
========================================

Phase 0: Initialization and Reset
Time 350000: Reset released, initial floor = 0
[PASS] Phase 0: Reset and Initialization

Phase 1: Case 1 - Movement Timing (2 seconds per floor)
...
[PASS] Case 1: Movement Timing

========================================
Test Summary
========================================
Total Tests: 11
Passed:      11
Failed:      0
========================================
ALL TESTS PASSED!
```

### Wave Window (Waveforms)
You'll see signals like:
- `floor` changing from 0 → 1 → 2 → 3, etc.
- `mv_up` and `mv_down` pulsing
- `door_open` pulsing at target floors
- FSM state transitions

## Troubleshooting

### Error: "can't read file run.do"
- Check you're in the right directory: `pwd`
- List files: `ls` or `dir`
- Make sure `run.do` is there

### Error: "can't find file X.sv"
- All `.sv` files must be in the same folder as `run.do`
- Use `ls` or `dir` to verify

### Error: Compilation errors
- Make sure you copied the FIXED versions of the files
- `request_resolver.sv` should say "Version: 1.1 - FIXED" in the header

### Simulation hangs
- This shouldn't happen in QuestaSim (unlike Icarus)
- If it does, press **Ctrl+C** in the Transcript window to stop
- Check the Transcript for error messages

## Quick Commands Reference

```tcl
# Change directory
cd "C:/your/path"

# Run script
do run.do

# Stop simulation
stop

# Restart simulation
restart -f

# Run again
run -all

# Clear wave window
wave clear

# Add all signals again
add wave *

# Zoom to fit
wave zoom full

# Save waveform format
write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave.do
```

---

**That's it!** The script does everything automatically. Just `cd` to your folder and `do run.do`.

