############################################################
BOARD='tangnano1k'
FAMILY='GW1NZ-1'
DEVICE='GW1NZ-LV1QN48C6/I5'

SRCS=$(wildcard *.vhd)
TOP=lcd16x2_ctrl_demo

# <target name>: <target dependencies>
# <tab> <target commands>

YOSYS_CMD=ghdl $(SRCS) -e $(TOP);
YOSYS_CMD+=synth_gowin -json synth.json

all: bitstream.fs
	@echo "Done..."

# Logic Synthesis
synth.json: $(SRCS)
	@echo "Starting the FPGA design flow..."
	yosys -m ghdl -p '$(YOSYS_CMD)'

# Place & Route Step
pnr.json: synth.json
	nextpnr-himbaechel \
		--json synth.json \
		--write pnr.json \
		--device ${DEVICE} \
		--vopt family=${FAMILY} \
		--vopt cst=${TOP}.cst \
		--freq 27

# Bitstream Generation
bitstream.fs: pnr.json
	gowin_pack -d ${FAMILY} -o bitstream.fs pnr.json

# Device Programming: upload bitstream to on-chip SRAM
upload_sram: bitstream.fs
	openFPGALoader -b ${BOARD} bitstream.fs

# Device Programming: upload bitstream to on-chip Flash
upload_flash: bitstream.fs
	openFPGALoader -b ${BOARD} bitstream.fs -f

clean:
	rm -f *.fs *.json *.cf *.o

# The following targets do not represent a file.
.PHONY: all clean upload_sram upload_flash

# The following files can be removed when finished.
.INTERMEDIATE: synth.json pnr.json
