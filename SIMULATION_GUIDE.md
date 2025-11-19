# Elevator Controller Simulation Guide

This guide explains how to run the elevator controller simulation, view the transcript output, and analyze waveforms to verify functionality.

## Prerequisites

- **Icarus Verilog** (`iverilog`) - for compilation
- **vvp** (Icarus Verilog runtime) - for simulation
- **GTKWave** - for waveform viewing
  - Install via: `brew install --HEAD randomplum/gtkwave/gtkwave`

## Quick Start

### 1. Run the Complete Simulation

```bash
cd "/Users/elshazlio/Library/CloudStorage/OneDrive-Personal/Documents/Library/ASIC/HW3"
make sim
```

This will:
- Compile all SystemVerilog files
- Run the simulation
- Generate `transcript.log` (text output)
- Generate `elevator_wave.vcd` (waveform file)

**Note:** The simulation may take 2-5 minutes to complete all 10 test cases. Be patient!

### 2. View the Transcript Output

The transcript shows test results and debug information. View it with:

```bash
# View the entire transcript
cat transcript.log

# Or watch it in real-time while simulation runs
tail -f transcript.log

# View last 50 lines
tail -50 transcript.log
```

**What to Look For:**
- `[PASS]` or `[FAIL]` indicators for each test case
- Test summary at the end showing total passed/failed tests
- Time stamps showing when events occur
- Floor numbers and state transitions

**Expected Output Structure:**
```
========================================
Elevator Controller Testbench
Simulation Start Time: 0
========================================

Phase 0: Initialization and Reset
Time 340000: Reset released, initial floor = 0
[PASS] Phase 0: Reset and Initialization

Phase 1: Case 1 - Movement Timing (2 seconds per floor)
...

========================================
Test Summary
========================================
Total Tests: 11
Passed:      11
Failed:      0
========================================
ALL TESTS PASSED!
```

### 3. View Waveforms in GTKWave

After simulation completes, open the waveform viewer:

```bash
make wave
```

Or manually:
```bash
gtkwave elevator_wave.vcd
```

#### GTKWave Navigation Guide

1. **Left Panel (SST - Signal Search Tree):**
   - Expand `elevator_top_tb` → `dut` to see all design signals
   - Expand sub-modules:
     - `u_request_resolver` - Request resolution logic
     - `u_unit_control` - FSM and movement control
     - `u_ssd` - Seven-segment display decoder

2. **Adding Signals to Waveform:**
   - **Method 1:** Select signal(s) → Right-click → "Insert"
   - **Method 2:** Drag signal from left panel to waveform area
   - **Method 3:** Double-click signal name

3. **Key Signals to Monitor:**

   **System Signals:**
   - `clk` - 50 MHz system clock
   - `reset_n` - Active-low reset signal
   
   **Inputs:**
   - `inside_buttons[9:0]` - Internal elevator buttons (b0-b9)
   - `up_buttons[8:0]` - External up buttons (up1-up9)
   - `dn_buttons[8:0]` - External down buttons (dn1-dn9)
   
   **Outputs:**
   - `floor[3:0]` - Current floor (0-9)
   - `mv_up` - Moving up indicator
   - `mv_down` - Moving down indicator
   - `door_open` - Door open indicator
   - `ssd_hex[6:0]` - Seven-segment display output
   
   **Internal Signals (in dut):**
   - `req[3:0]` - Resolved target floor
   - `req_valid` - Valid request signal
   - `current_direction[1:0]` - Current direction (0=IDLE, 1=UP, 2=DOWN)
   - `control_enable` - 1 Hz enable signal (pulses every 100 clock cycles)
   
   **FSM State (in u_unit_control):**
   - `current_state[2:0]` - FSM state (0=IDLE, 1=MOVING_UP, 2=MOVING_DOWN, 3=DOOR_OPEN)

4. **Waveform Analysis Tips:**
   - **Zoom:** Use mouse wheel or zoom buttons
   - **Navigate:** Drag the timeline or use arrow keys
   - **Measure Time:** Click and drag to measure time intervals
   - **Search:** Use Ctrl+F to find specific time values

5. **Verification Checklist:**

   ✅ **Movement Timing:**
   - Verify elevator takes 2 enable cycles (200 clock cycles) per floor
   - Check `mv_up`/`mv_down` signals during movement
   
   ✅ **Door Control:**
   - Verify `door_open` is HIGH for ≥2 enable cycles at target floor
   - Verify `door_open` is LOW during movement (`mv_up` or `mv_down`)
   
   ✅ **Direction Persistence:**
   - Verify elevator doesn't change direction until all requests in current direction are served
   
   ✅ **Request Prioritization:**
   - Verify requests in current direction are served first
   - Verify proper sequencing of multiple requests
   
   ✅ **State Transitions:**
   - Verify FSM transitions: IDLE → MOVING_UP/DOWN → DOOR_OPEN → IDLE
   - Verify state changes occur at correct times

## Step-by-Step Workflow

### Complete Simulation and Analysis:

```bash
# 1. Clean previous results (optional)
make clean

# 2. Run simulation (this may take a few minutes)
make sim

# 3. Check if simulation completed successfully
tail -20 transcript.log

# 4. Open waveforms
make wave

# 5. In GTKWave, add signals and verify functionality
```

### If Simulation Hangs:

If the simulation appears stuck (no output for >5 minutes):

1. **Check if process is running:**
   ```bash
   ps aux | grep vvp
   ```

2. **Kill stuck processes:**
   ```bash
   pkill -9 vvp
   ```

3. **Check for errors:**
   ```bash
   tail -50 transcript.log
   ```

4. **Re-run simulation:**
   ```bash
   make clean
   make sim
   ```

## Understanding the Test Cases

The testbench runs 10 test cases (plus initialization):

1. **Phase 0:** Reset and Initialization
2. **Phase 1:** Movement Timing (2 seconds per floor)
3. **Phase 2:** Door Duration (≥2 seconds open)
4. **Phase 3:** Direction Persistence
5. **Phase 4:** Request Prioritization
6. **Phase 5:** Bounds Handling (ignore invalid requests)
7. **Phase 6:** Multiple Simultaneous Requests
8. **Phase 7:** Same Floor Request (immediate door open)
9. **Phase 8:** Intermediate Stop
10. **Phase 9:** Combined Internal/External Requests
11. **Phase 10:** Error Handling

Each test case should show `[PASS]` or `[FAIL]` in the transcript.

## Troubleshooting

### Problem: Simulation appears stuck after "Phase 0: Initialization and Reset"
**Solution:** This is normal! The simulation is working but may take 1-3 minutes to complete all tests. The testbench uses time-based delays that make it appear slow. 

**To verify it's working:**
```bash
# In another terminal, watch the progress
tail -f transcript.log
```

**If it's truly stuck (>5 minutes with no new output):**
```bash
# Kill stuck processes
pkill -9 vvp

# Clean and recompile
make clean
make sim
```

**Note:** The simulation has been optimized with `ENABLE_CYCLES = 10` for faster execution. If you need even faster simulation, you can reduce this value further in `elevator_top_tb.sv` (line 38), but this changes the timing relationship.

### Problem: "gtkwave: command not found"
**Solution:** Install GTKWave:
```bash
brew install --HEAD randomplum/gtkwave/gtkwave
```

### Problem: Simulation runs but produces no output
**Solution:** 
- Check that `transcript.log` file is being created
- Add `$fflush()` calls in testbench (already added)
- Check compilation warnings
- Wait for simulation to complete (may take 1-3 minutes)

### Problem: Waveforms show no signals
**Solution:**
- Ensure simulation completed successfully
- Check that `elevator_wave.vcd` file exists and has size > 0
- Verify `$dumpvars(0, elevator_top_tb)` is called in testbench

### Problem: Can't see internal signals in GTKWave
**Solution:**
- Expand the hierarchy in the left panel
- Look under `elevator_top_tb` → `dut` → `u_request_resolver` or `u_unit_control`
- Internal signals may need to be added manually if not dumped

## Makefile Targets

- `make clean` - Remove generated files (sim.out, transcript.log, elevator_wave.vcd)
- `make compile` - Compile only (no simulation)
- `make sim` - Compile and run simulation
- `make wave` - Open GTKWave (requires simulation to complete first)
- `make all` - Complete flow: compile → simulate → view waveforms
- `make run` - Run existing simulation without recompiling

## Expected Simulation Time

- **Fast simulation mode:** Uses `ENABLE_CYCLES = 10` (10 clock cycles per enable)
- **Total simulation time:** ~30 seconds to 2 minutes depending on system
- **Waveform file size:** ~1-10 MB (depends on dump depth)

**Note:** The simulation may appear to hang after "Phase 0: Initialization and Reset" but it's actually progressing. Be patient - it will complete all 10 test cases. You can monitor progress with `tail -f transcript.log` in another terminal.

## Manual Verification Steps

1. **Check Transcript:**
   - All tests should show `[PASS]`
   - Test summary should show 0 failures
   - Verify timing information matches expectations

2. **Check Waveforms:**
   - Verify floor transitions occur at correct intervals
   - Verify door opens/closes correctly
   - Verify movement signals are correct
   - Verify no violations (door open during movement, etc.)

3. **Verify Specific Test Cases:**
   - Use GTKWave's search function to jump to specific test phases
   - Measure time intervals between events
   - Verify state machine transitions

## Additional Notes

- The simulation uses a fast mode where `control_enable` pulses every 100 clock cycles instead of 50 million (for practical simulation time)
- Real hardware would use 50 MHz clock with 1 Hz enable (50 million cycles per second)
- All timing relationships are preserved, just scaled for faster simulation

---

**Happy Simulating! 🚀**

For issues or questions, check the transcript.log file for error messages and debug output.

