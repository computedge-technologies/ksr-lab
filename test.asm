; Test Program: Simple loop to add numbers 1 to 5
LDI R1, 0      ; sum = 0
LDI R2, 5      ; counter = 5
loop:
    ADD R1, R1, R2 ; sum += counter
    ADDI R2, R2, -1 ; counter -= 1 (using ADDI with negative)
    BNE loop       ; repeat while counter != 0
NOP                ; finish
