# Makefile for VHDL simulation with GHDL

# Top-level entity for testbench
TOP = counter_tb

# Source files
SOURCE_FILES := counter.vhd counter_tb.vhd

# GHDL executable
GHDL := ghdl

# GHDL flags
GHDL_FLAGS := --std=08 -fsynopsys

# Simulation options
SIM_OPTIONS := --vcd=waveform.vcd --stop-time=10us

# Targets
all: compile simulate

compile:
	$(GHDL) -a $(GHDL_FLAGS) $(SOURCE_FILES)

simulate:
	$(GHDL) -e $(GHDL_FLAGS) $(TOP)
	$(GHDL) -r $(GHDL_FLAGS) $(TOP) $(SIM_OPTIONS)

clean:
	rm -f *.o *.cf *.vcd $(TOP)

.PHONY: all compile simulate clean
