# ==================================================================
# NanoCore16 Assembly code generation Makefile
# ==================================================================

#Environment
WORKAREA ?= $(HOME)/Projects/NanoCore16

#Toolchain
TOOLCHAIN_DIR := $(WORKAREA)/toolchain
#ASSEMBLER     := $(TOOLCHAIN_DIR)/nanocore16_toolchain
ASSEMBLER     := python3 $(TOOLCHAIN_DIR)/assembler.py

#Test directories
TEST_DIR := $(WORKAREA)/verif/tests
OUT_DIR  := $(WORKAREA)/src/rtl


# Default test name, can be overridden

TEST ?= arith/add

ASM_FILE := $(TEST_DIR)/$(TEST).asm
HEX_FILE := $(OUT_DIR)/inst_mem.hex

# ==================================================================
# Makefile targets
# ==================================================================
.PHONY: all compile clean help

compile: $(HEX_FILE)

$(HEX_FILE) : $(ASM_FILE)
	@echo "------------------------------------------------------"
	@echo "Assembling NanoCore16 Test: "
	@echo "    ASM  : $(ASM_FILE) : "
	@echo "    HEX  : $(HEX_FILE) : "
	@echo "------------------------------------------------------"
	$(ASSEMBLER) $< $@
	#${WORKAREA}/toolchain/nanocore16_toolchain ${test_name}

clean:
	@echo "Cleaning generated hex files..."
	@find $(OUT_DIR) -name "*.hex" -delete

help:
	@echo "NanoCore16 Verification Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make compile TEST=arith/add"
	@echo "  make compile TEST=logic/and"
	@echo "  make clean"
	@echo ""
	@echo "Environment:"
	@echo "  WORKAREA=$(WORKAREA)"	

