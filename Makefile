#******************************************************************************
# File: Makefile
# Author: Generated for ECNG410401 ASIC Design Using CAD
# Title: Elevator Controller Build Script
# Version: 1.0
# Date: November 13, 2025
#******************************************************************************
# Description: Build script for Icarus Verilog compilation and simulation
#              of the elevator controller system.
#
# Targets:
#   all:     Complete build, simulate, and view waveforms
#   compile: Compile SystemVerilog sources
#   sim:     Run simulation and generate transcript
#   wave:    Open waveform viewer (GTKWave)
#   clean:   Remove generated files
#
# Usage:
#   make all     - Run complete flow
#   make clean   - Clean up generated files
#******************************************************************************

# Tool configuration
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Compiler flags
IVERILOG_FLAGS = -g2012

# File names
SIM_OUT = sim.out
TRANSCRIPT = transcript.log
WAVEFORM = elevator_wave.vcd

# Source files
SOURCES = elevator_top.sv \
          request_resolver.sv \
          unit_control.sv \
          ssd.sv \
          elevator_top_tb.sv

# Default target
.PHONY: all
all: compile sim wave

# Compile SystemVerilog sources
.PHONY: compile
compile:
	@echo "========================================="
	@echo "Compiling SystemVerilog sources..."
	@echo "========================================="
	$(IVERILOG) $(IVERILOG_FLAGS) -o $(SIM_OUT) $(SOURCES)
	@echo "Compilation successful!"
	@echo ""

# Run simulation
.PHONY: sim
sim: compile
	@echo "========================================="
	@echo "Running simulation..."
	@echo "========================================="
	$(VVP) $(SIM_OUT) | tee $(TRANSCRIPT)
	@echo ""
	@echo "Simulation complete. Results in $(TRANSCRIPT)"
	@echo ""

# View waveforms
.PHONY: wave
wave:
	@echo "========================================="
	@echo "Opening waveform viewer..."
	@echo "========================================="
	@if [ -f $(WAVEFORM) ]; then \
		$(GTKWAVE) $(WAVEFORM) & \
		echo "GTKWave launched with $(WAVEFORM)"; \
	else \
		echo "Error: Waveform file $(WAVEFORM) not found."; \
		echo "Run 'make sim' first to generate waveforms."; \
	fi
	@echo ""

# Run only compilation (no simulation)
.PHONY: build
build: compile

# Run simulation without recompiling
.PHONY: run
run:
	@echo "========================================="
	@echo "Running existing simulation..."
	@echo "========================================="
	@if [ -f $(SIM_OUT) ]; then \
		$(VVP) $(SIM_OUT) | tee $(TRANSCRIPT); \
	else \
		echo "Error: Compiled simulation $(SIM_OUT) not found."; \
		echo "Run 'make compile' first."; \
	fi
	@echo ""

# Clean generated files
.PHONY: clean
clean:
	@echo "========================================="
	@echo "Cleaning generated files..."
	@echo "========================================="
	rm -f $(SIM_OUT) $(TRANSCRIPT) $(WAVEFORM)
	@echo "Clean complete."
	@echo ""

# Help target
.PHONY: help
help:
	@echo "========================================="
	@echo "Elevator Controller Makefile"
	@echo "========================================="
	@echo "Available targets:"
	@echo "  all      - Compile, simulate, and view waveforms (default)"
	@echo "  compile  - Compile SystemVerilog sources only"
	@echo "  sim      - Compile and run simulation"
	@echo "  wave     - Open waveform viewer (GTKWave)"
	@echo "  run      - Run existing simulation without recompiling"
	@echo "  clean    - Remove all generated files"
	@echo "  help     - Display this help message"
	@echo ""
	@echo "Source files:"
	@echo "  $(SOURCES)"
	@echo ""
	@echo "Generated files:"
	@echo "  $(SIM_OUT)    - Compiled simulation executable"
	@echo "  $(TRANSCRIPT) - Simulation output log"
	@echo "  $(WAVEFORM)   - VCD waveform file"
	@echo "========================================="


