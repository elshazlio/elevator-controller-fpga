# Fixed Elevator Controller - Commands to Run

## What Was Wrong
The `request_resolver.sv` had for-loops with variable bounds that caused Icarus Verilog to hang. I've fixed it by replacing the loops with explicit priority encoders.

## Commands to Run

```bash
cd "/Users/elshazlio/Library/CloudStorage/OneDrive-Personal/Documents/Library/ASIC/HW3"

# Clean previous attempts
make clean

# Run simulation
make sim

# View waveforms
make wave
```

The simulation should now complete in ~30 seconds to 2 minutes and produce:
- `transcript.log` with test results
- `elevator_wave.vcd` with waveforms

## In GTKWave

After opening GTKWave, **double-click these signals** to add them:
1. `clk`
2. `reset_n`
3. `floor[3:0]` ← most important
4. `mv_up`
5. `mv_down`
6. `door_open`
7. `inside_buttons[9:0]`

Then click "Zoom Fit" or press Alt+Z.

## Expected Results

You should see:
- Floor changing from 0 → 1 → 2 → 3, etc.
- `mv_up` and `mv_down` pulsing during movement
- `door_open` pulsing when at target floors
- All 11 tests passing in transcript.log

---

**If it still hangs:** There may be another issue. Let me know and I'll investigate further.

