# Quick Reference - Elevator Controller Simulation

## Essential Commands

```bash
# Navigate to project directory
cd "/Users/elshazlio/Library/CloudStorage/OneDrive-Personal/Documents/Library/ASIC/HW3"

# Run complete simulation (compiles + simulates)
make sim

# View transcript output
cat transcript.log
tail -f transcript.log          # Watch in real-time

# Open waveforms
make wave
# OR
gtkwave elevator_wave.vcd

# Clean and start fresh
make clean && make sim
```

## What to Check

### ✅ Transcript (`transcript.log`)
- Look for: `[PASS]` or `[FAIL]` for each test
- Check: Test summary at the end
- Verify: All 11 tests pass

### ✅ Waveforms (GTKWave)
**Key Signals to Add:**
- `clk`, `reset_n`
- `floor[3:0]` - Current floor
- `mv_up`, `mv_down`, `door_open`
- `inside_buttons[9:0]`
- `current_state[2:0]` (in u_unit_control)

**Verify:**
- Floor changes every 2 enable cycles (200 clock cycles)
- Door opens for ≥2 enable cycles
- Door never open during movement
- Correct state transitions

## If Something Goes Wrong

```bash
# Kill stuck simulation
pkill -9 vvp

# Check what's running
ps aux | grep vvp

# Clean and retry
make clean
make sim
```

## Expected Results

- **Simulation Time:** 2-5 minutes
- **Test Results:** All 11 tests should PASS
- **Waveform File:** `elevator_wave.vcd` should be created
- **Transcript:** Should show detailed test output

---

See `SIMULATION_GUIDE.md` for detailed instructions.

