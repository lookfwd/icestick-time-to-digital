# Makefile for iCEstick Time-to-Digital Converter
# Uses open-source iCE40 toolchain: yosys, nextpnr-ice40, icestorm

# Project settings
TOP = top
SOURCES = src/top.v src/pll.v src/tdc_core.v src/delay_line.v src/uart_tx.v
PCF = icestick.pcf

# iCE40 settings for iCEstick (HX1K in TQ144 package)
DEVICE = hx1k
PACKAGE = tq144

# Output files
JSON = build/$(TOP).json
ASC = build/$(TOP).asc
BIN = build/$(TOP).bin
RPT = build/$(TOP).rpt

# Default target
all: $(BIN)

# Create build directory
build:
	mkdir -p build

# Synthesis with yosys
synth: build $(JSON)

$(JSON): $(SOURCES) | build
	yosys -p "synth_ice40 -top $(TOP) -json $@" $(SOURCES)

# Place and route with nextpnr
pnr: $(ASC)

$(ASC): $(JSON) $(PCF)
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --json $(JSON) --pcf $(PCF) --asc $@ --report $(RPT)

# Pack bitstream with icepack
pack: $(BIN)

$(BIN): $(ASC)
	icepack $< $@

# Program the iCEstick
prog: $(BIN)
	iceprog $<

# Timing analysis
timing: $(ASC)
	icetime -d $(DEVICE) -mtr $(RPT) $<

# Clean build artifacts
clean:
	rm -rf build

# Show resource usage
stats: $(JSON)
	yosys -p "synth_ice40 -top $(TOP)" $(SOURCES) 2>&1 | grep -E "(cells|wires|LUT|DFF|CARRY|RAM|PLL)"

.PHONY: all synth pnr pack prog timing clean stats
