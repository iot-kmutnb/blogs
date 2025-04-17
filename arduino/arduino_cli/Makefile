# === Configurable Variables ===
SKETCH_DIR  ?= $(shell pwd)
SKETCH_NAME ?= $(notdir $(SKETCH_DIR))
BOARD_FQBN  ?= esp32:esp32:esp32
PORT        ?= /dev/ttyUSB0
BAUD        ?= 115200

# === Commands ===
CLI := arduino-cli

# === Sketch Info ===
SKETCH_NAME := $(notdir $(SKETCH_DIR))
BUILD_DIR   := $(SKETCH_DIR)/build

# === Targets ===
.PHONY: all create compile upload monitor clean

all: compile upload

create:
	@echo "Creating sketch in $(SKETCH_DIR)..."
	$(CLI) sketch new $(SKETCH_DIR)

compile:
	@echo "Compiling sketch and source files in $(SKETCH_DIR)..."
	$(CLI) compile --verbose --fqbn $(BOARD_FQBN) --build-path $(BUILD_DIR) $(SKETCH_DIR)

upload:
	@echo "Uploading to board on $(PORT)..."
	$(CLI) upload -p $(PORT) --fqbn $(BOARD_FQBN) --input-dir $(BUILD_DIR)

monitor:
	@echo "Starting serial monitor on $(PORT)..."
	$(CLI) monitor -p $(PORT) -c baudrate=$(BAUD) --fqbn $(BOARD_FQBN)

clean:
	@echo "Cleaning build directory..."
	rm -rf $(BUILD_DIR)
