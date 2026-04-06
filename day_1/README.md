# SimpleProc Toolchain Documentation

The `sim_proc_toolchain` is a custom assembler designed to convert assembly code for the SimpleProc ISA into hex files compatible with `$readmemh`.

## Usage

```bash
./toolchain/sim_proc_toolchain <input.asm> [output.hex]
```

## Assembly Syntax

### Registers
- Use `R0` through `R15`.
- `R0` is hardwired to zero in the hardware.

### Opcodes & Format
- **Arithmetic**: `ADD Rd, RS1, RS2` | `SUB Rd, RS1, RS2` | `ADDI Rd, RS1, IMM`
- **Logic**: `AND Rd, RS1, RS2` | `OR Rd, RS1, RS2` | `XOR Rd, RS1, RS2` | `INV Rd, RS1`
- **Shift**: `SHL Rd, RS1, IMM` | `SHR Rd, RS1, IMM`
- **Data**: `LDI Rd, IMM` | `MOV Rd, RS1`
- **Comparison**: `CMP RS1, RS2` (sets flags)
- **Control**: 
    - `JMP RS1, IMM` (PC = RS1 + IMM)
    - `BEQ label` (Branch if zero flag set)
    - `BNE label` (Branch if zero flag not set)

### Constants
- Decimal: `5`, `-3`
- Hex: `0xA`, `0xF`

### Labels & Comments
- Labels end with a colon: `loop:`
- Comments start with a semicolon: `; This is a comment`

## Example (`sum.asm`)
```assembly
LDI R1, 0      ; R1 = sum
LDI R2, 10     ; R2 = counter
loop:
    ADD R1, R1, R2 ; sum = sum + counter
    SUB R2, R2, R1 ; just an example
    BNE loop       ; repeat until counter is 0
```
