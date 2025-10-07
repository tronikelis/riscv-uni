# vim:filetype=asmh

.global _start

.text

_start:
    # argv
    lw s1, 8(sp)
    mv a0, s1
    call print_string

    li a0, 10
    call print_char

    mv a0, s1
    call strlen

    # s2 = word count
    li s2, 1

    # s10 = i
    li s10, 0
    # s11 = strlen
    mv s11, a0
.L_loop_start:
    add t2, s1, s10
    # t2 = argv[t2]
    lbu t2, 0(t2)

    li t3, 32
    bne t3, t2, .L_if_space_end
    addi s2, s2, 1
.L_if_space_end:

    addi s10, s10, 1
    blt s10, s11, .L_loop_start

    # word count to string
    addi sp, sp, -16
    mv a0, s2
    mv a1, sp
    call itoa

    # t6 = strlen(word count string)
    mv a0, sp
    call strlen
    mv t6, a0

    li a7, 64
    li a0, 1
    mv a1, sp
    mv a2, t6
    ecall

    # exit
    li a7, 93
    li a0, 0
    ecall
