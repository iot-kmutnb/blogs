filename = leds
pcf_file = $(filename).pcf

build:
	yosys -p 'synth_ice40 -top $(filename) -json $(filename).json' $(filename).v
	nextpnr-ice40 \
		--up5k --package sg48 \
		--json $(filename).json \
		--pcf $(pcf_file) \
		--asc $(filename).asc
	icepack $(filename).asc $(filename).bin

clean:
	rm -rf $(filename).blif $(filename).asc $(filename).bin $(filename).json
