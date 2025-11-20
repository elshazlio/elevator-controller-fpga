# FPGA Elevator Controller

A SystemVerilog implementation of a multi-floor elevator controller designed for the **Altera DE0-CV FPGA** (Cyclone V 5CEBA4F23C7). This project includes a complete FSM-based control system, request resolution logic, and hardware interface wrappers.

## 🚀 Features

- **10-Floor Support**: Controls movement between floors 0-9.
- **Smart Request Resolution**: Handles multiple simultaneous requests with direction-based priority (like a real elevator).
- **FSM Control**: Robust state machine managing Idle, Moving Up, Moving Down, and Door operations.
- **Hardware Interface**:
  - **Switches (SW[9:0])**: Inside elevator floor requests.
  - **LEDs**: Direction indicators (Up/Down) and Door Open status.
  - **7-Segment Display**: Real-time current floor display.
- **Configurable Timing**: Parametrized movement and door timing (default 2s per floor/action).
- **Clock Division**: Downscales 50MHz system clock to 1Hz control logic.

## 📁 Project Structure

```text
.
├── elevator_top.sv          # Core top-level module with clock divider
├── elevator_top_fpga.sv     # FPGA wrapper for DE0-CV board
├── request_resolver.sv      # Priority logic for button requests
├── unit_control.sv          # Main FSM controller
├── ssd.sv                   # 7-segment display decoder
├── elevator_top_tb.sv       # SystemVerilog testbench
├── run.do                   # QuestaSim simulation script
├── fix_pins.tcl             # Tcl script for pin assignment
└── Documentation/           # Guides for FPGA and Simulation
```

## 🛠️ Getting Started

### Prerequisites

- **Intel Quartus Prime** (for FPGA synthesis)
- **Siemens QuestaSim** or **ModelSim** (for simulation)
- **Altera DE0-CV Board** (optional, for hardware deployment)

### Simulation (QuestaSim)

1. Open QuestaSim/ModelSim.
2. Navigate to the project directory.
3. Run the simulation script:
   ```tcl
   do run.do
   ```
   This will compile all files and run the testbench `elevator_top_tb.sv`.

### FPGA Implementation (Quartus)

1. **Create Project**: Open Quartus Prime and create a new project targeting **Cyclone V 5CEBA4F23C7**.
2. **Add Files**: Include all `.sv` files. Set `elevator_top_fpga.sv` as the top-level entity.
3. **Assign Pins**: Run the provided Tcl script to map pins automatically:
   ```tcl
   source fix_pins.tcl
   ```
   *(Or refer to `PIN_CONNECTIONS.txt` for manual assignment)*
4. **Compile**: Run "Start Compilation".
5. **Program**: Connect the DE0-CV board and program the `.sof` file via USB Blaster.

## 📖 Documentation

Detailed guides are included in the repository:

- [**FPGA Implementation Guide**](FPGA_IMPLEMENTATION_GUIDE.md): Step-by-step Quartus setup and deployment.
- [**FPGA Quickstart**](FPGA_QUICKSTART.md): Condensed guide for experienced users.
- [**Simulation Guide**](SIMULATION_GUIDE.md): How to run and view simulations.
- [**Pin Connections**](PIN_CONNECTIONS.txt): Reference for board pin mappings.

## 🧩 Hardware Mapping (DE0-CV)

| Board Component | Function |
|-----------------|----------|
| **CLOCK_50** | System Clock (50 MHz) |
| **KEY[0]** | Reset (Active Low) |
| **SW[9:0]** | Floor Requests (Floor 0 - 9) |
| **LEDR[0]** | Moving Up Indicator |
| **LEDR[1]** | Moving Down Indicator |
| **LEDR[2]** | Door Open Indicator |
| **HEX0** | Current Floor Display |

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
*Author: Omar ElShazli | Course: ECNG410401 ASIC Design Using CAD*

Feel free to contact me if you find any issues or bugs, or better yet, fix them!

