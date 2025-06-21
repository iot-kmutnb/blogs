############################################################
BOARD='tangnano9k'
FAMILY='GW1N-9C'
DEVICE='GW1NR-LV9QN88PC6/I5'

SRCS=$(wildcard *.v)
TOP=leds_running

# <target name>: <target dependencies>
# <target commands>

YOSYS_CMD=read_verilog $(SRCS);
YOSYS_CMD+=synth_gowin -top ${TOP} -json synth.json

all: bitstream.fs
	@echo "Done..."

# Logic Synthesis
synth.json: $(SRCS)
	@echo "Starting the FPGA design flow..."
	yosys -p '$(YOSYS_CMD)'

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

