# vim:filetype=asmh

.global _start

.data

target: 
   .word 0

positive_string:
    .asciz "positive"

negative_string:
    .asciz "negative"

zero_string:
    .asciz "zero"

.text

_start:
    la s1, target
    lw s1, 0(s1)
    # s1 == 0
    beqz s1, .L_zero

    # or you could just use bltz
    # s1 >> 31
    li t0, 31
    srl s1, s1, t0
    

    li t0, 1
    # s1 == 1
    beq s1, t0, .L_negative_string
    # s1 == 0
    la a0, positive_string
    call print_string
    j .L_end
     
.L_negative_string:
    la a0, negative_string
    call print_string
    j .L_end

.L_zero:
    la a0, zero_string
    call print_string

.L_end:
    li a7, 93
    li a0, 0
    ecall


