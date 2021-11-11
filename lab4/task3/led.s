.global _start
_start:
    movui r2, 0xaa
    movui r3, 0x00000000
    stwio r2, 0(r3)
loop:
    beq zero, zero, loop