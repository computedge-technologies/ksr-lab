#!/usr/bin/env python3
import sys
import re

# ISA Mapping
OPCODES = {
    'ADD':  0x0,
    'SUB':  0x1,
    'ADDI': 0x2,
    'AND':  0x3,
    'OR':   0x4,
    'XOR':  0x5,
    'INV':  0x6,
    'SHL':  0x7,
    'SHR':  0x8,
    'LDI':  0x9,
    'MOV':  0xA,
    'CMP':  0xB,
    'JMP':  0xC,
    'BEQ':  0xD,
    'BNE':  0xE,
    'NOP':  0xF
}

REGISTERS = {f'R{i}': i for i in range(16)}

def parse_int(val):
    if val.startswith('0x'):
        return int(val, 16)
    return int(val)

def assemble(input_file):
    labels = {}
    instructions = []
    
    # Pass 1: Collect labels
    with open(input_file, 'r') as f:
        addr = 0
        for line in f:
            line = line.split(';')[0].strip() # Remove comments
            if not line: continue
            
            if line.endswith(':'):
                labels[line[:-1]] = addr
            else:
                instructions.append((addr, line))
                addr += 1

    binary_output = []
    
    # Pass 2: Generate machine code
    for addr, line in instructions:
        parts = re.split(r'[,\s]+', line)
        mnemonic = parts[0].upper()
        
        if mnemonic not in OPCODES:
            print(f"Error at address {addr}: Unknown mnemonic {mnemonic}")
            sys.exit(1)
            
        opcode = OPCODES[mnemonic]
        rd = 0
        rs1 = 0
        rs2_imm = 0
        
        try:
            if mnemonic in ['ADD', 'SUB', 'AND', 'OR', 'XOR']:
                # R-type: MNEMONIC Rd, RS1, RS2
                rd = REGISTERS[parts[1].upper()]
                rs1 = REGISTERS[parts[2].upper()]
                rs2_imm = REGISTERS[parts[3].upper()]
            
            elif mnemonic in ['ADDI']:
                # I-type: ADDI Rd, RS1, IMM
                rd = REGISTERS[parts[1].upper()]
                rs1 = REGISTERS[parts[2].upper()]
                rs2_imm = parse_int(parts[3]) & 0xF
                
            elif mnemonic in ['INV', 'MOV', 'CMP']:
                # R-type (partial): MNEMONIC Rd, RS1 (or RS1, RS2 for CMP)
                if mnemonic == 'CMP':
                    # CMP RS1, RS2 -> [15:12] OPCODE, [11:8] Rd (ignored), [7:4] RS1, [3:0] RS2
                    rs1 = REGISTERS[parts[1].upper()]
                    rs2_imm = REGISTERS[parts[2].upper()]
                else:
                    rd = REGISTERS[parts[1].upper()]
                    rs1 = REGISTERS[parts[2].upper()]
                
            elif mnemonic in ['SHL', 'SHR']:
                # I-type: SHIFT Rd, RS1, IMM
                rd = REGISTERS[parts[1].upper()]
                rs1 = REGISTERS[parts[2].upper()]
                rs2_imm = parse_int(parts[3]) & 0x7 # Only 3 bits for shift
                
            elif mnemonic in ['LDI']:
                # I-type: LDI Rd, IMM
                rd = REGISTERS[parts[1].upper()]
                rs2_imm = parse_int(parts[2]) & 0xF
                
            elif mnemonic in ['JMP']:
                # J-type: JMP RS1, IMM (Relative or absolute based on implementation)
                # For this ISA: PC <- RS1 + sign_ext(IMM4)
                rs1 = REGISTERS[parts[1].upper()]
                rs2_imm = parse_int(parts[2]) & 0xF
            
            elif mnemonic in ['BEQ', 'BNE']:
                # J-type: BEQ IMM (Target label)
                # PC <- PC + sign_ext(IMM4)
                target = parts[1]
                if target in labels:
                    offset = labels[target] - (addr + 1) # Relative to next PC
                    rs2_imm = offset & 0xF
                else:
                    rs2_imm = parse_int(target) & 0xF
            
            elif mnemonic == 'NOP':
                pass

        except (IndexError, KeyError) as e:
            print(f"Error at address {addr}: Invalid arguments for {mnemonic}")
            sys.exit(1)
            
        # Encode: [15:12] OPCODE, [11:8] Rd, [7:4] RS1, [3:0] RS2/IMM
        instr_val = (opcode << 12) | (rd << 8) | (rs1 << 4) | (rs2_imm & 0xF)
        binary_output.append(f"{instr_val:04X}")
        
    return binary_output

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: assembler.py <input.asm> [output.hex]")
        sys.exit(1)
        
    input_asm = sys.argv[1]
    output_hex = sys.argv[2] if len(sys.argv) > 2 else "inst_mem.hex"
    
    hex_code = assemble(input_asm)
    with open(output_hex, 'w') as f:
        for line in hex_code:
            f.write(line + '\n')
            
    print(f"Assembly successful. Output written to {output_hex}")
