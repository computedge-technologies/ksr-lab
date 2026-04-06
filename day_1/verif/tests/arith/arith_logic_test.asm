; arith_logic_test.asm
; Test basic arithmetic and logic operations

; 1. Load Immediates
LDI R1, 5       ; R1 = 5
LDI R2, 3       ; R2 = 3

; 2. Arithmetic
ADD R3, R1, R2  ; R3 = 5 + 3 = 8
SUB R4, R1, R2  ; R4 = 5 - 3 = 2
ADDI R5, R1, 4  ; R5 = 5 + 4 = 9 (I-type)

; 3. Logic
AND R6, R1, R2  ; R6 = 5 & 3 = 1
OR  R7, R1, R2  ; R7 = 5 | 3 = 7
XOR R8, R1, R2  ; R8 = 5 ^ 3 = 6
INV R9, R1      ; R9 = ~5 = 0xFA (since datapath is 8-bit)

; 4. Shift
LDI R10, 1
SHL R11, R10, 2 ; R11 = 1 << 2 = 4
SHR R12, R11, 1 ; R12 = 4 >> 1 = 2

; 5. Compare and Conditional Branch
CMP R1, R2      ; 5 - 3 != 0 (Zero flag = 0)
BEQ fail        ; Should not branch
LDI R13, 0xA    ; success indicator
BNE success     ; Should branch

fail:
    LDI R13, 0xF ; failure marker
    NOP

success:
    LDI R14, 0x1 ; success marker
    NOP

NOP             ; End of program
