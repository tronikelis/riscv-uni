# vim:filetype=asmh

.global _start

.text

_start:
    li s1, 0
    li s2, 100
.L_loop:
    addi sp, sp, -16

    mv a0, s1
    mv a1, sp
    call itoa

    # strlen(sp)
    mv a0, sp
    call strlen
    mv a2, a0

    # write(1, sp, strlen(sp))
    li a7, 64
    li a0, 1
    mv a1, sp
    ecall

    call fn_print_newline

    addi sp, sp, 16
    addi s1, s1, 1
    blt s1, s2, .L_loop

    # exit
    li a7, 93
    li a0, 0
    ecall

fn_print_newline:
    addi sp, sp, -16
    sw s0, 4(sp)

    li s0, 10
    sw s0, 0(sp)

    # write(1, sp, 2)
    li a7, 64
    li a0, 1
    mv a1, sp
    li a2, 1
    ecall

    lw s0, 4(sp)
    addi sp, sp, 16
    ret
