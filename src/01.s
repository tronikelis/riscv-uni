# vim:filetype=asmh

.global _start

.text

strlen:
    addi    sp, sp, -16
    sw      ra, 12(sp)
    sw      s0, 8(sp)
    addi    s0, sp, 16
    sw      a0, -12(s0)
    li      a0, 0
    sw      a0, -16(s0)
    j       .LBB0_1
.LBB0_1:
    lw      a0, -12(s0)
    lw      a1, -16(s0)
    add     a0, a0, a1
    lbu     a0, 0(a0)
    beqz    a0, .LBB0_3
    j       .LBB0_2
.LBB0_2:
    lw      a0, -16(s0)
    addi    a0, a0, 1
    sw      a0, -16(s0)
    j       .LBB0_1
.LBB0_3:
    lw      a0, -16(s0)
    lw      ra, 12(sp)
    lw      s0, 8(sp)
    addi    sp, sp, 16
    ret

reverse:
    addi    sp, sp, -32
    sw      ra, 28(sp)
    sw      s0, 24(sp)
    addi    s0, sp, 32
    sw      a0, -12(s0)
    li      a0, 0
    sw      a0, -16(s0)
    lw      a0, -12(s0)
    call    strlen
    addi    a0, a0, -1
    sw      a0, -20(s0)
    j       .LBB1_1
.LBB1_1:
    lw      a0, -16(s0)
    lw      a1, -20(s0)
    bge     a0, a1, .LBB1_4
    j       .LBB1_2
.LBB1_2:
    lw      a0, -12(s0)
    lw      a1, -16(s0)
    add     a0, a0, a1
    lbu     a0, 0(a0)
    sb      a0, -21(s0)
    lw      a1, -12(s0)
    lw      a0, -20(s0)
    add     a0, a0, a1
    lbu     a0, 0(a0)
    lw      a2, -16(s0)
    add     a1, a1, a2
    sb      a0, 0(a1)
    lbu     a0, -21(s0)
    lw      a1, -12(s0)
    lw      a2, -20(s0)
    add     a1, a1, a2
    sb      a0, 0(a1)
    j       .LBB1_3
.LBB1_3:
    lw      a0, -16(s0)
    addi    a0, a0, 1
    sw      a0, -16(s0)
    lw      a0, -20(s0)
    addi    a0, a0, -1
    sw      a0, -20(s0)
    j       .LBB1_1
.LBB1_4:
    lw      ra, 28(sp)
    lw      s0, 24(sp)
    addi    sp, sp, 32
    ret

itoa:
    addi    sp, sp, -32
    sw      ra, 28(sp)
    sw      s0, 24(sp)
    addi    s0, sp, 32
    sw      a0, -12(s0)
    sw      a1, -16(s0)
    lw      a0, -12(s0)
    sw      a0, -24(s0)
    bgez    a0, .LBB2_2
    j       .LBB2_1
.LBB2_1:
    lw      a1, -12(s0)
    li      a0, 0
    sub     a0, a0, a1
    sw      a0, -12(s0)
    j       .LBB2_2
.LBB2_2:
    li      a0, 0
    sw      a0, -20(s0)
    j       .LBB2_3
.LBB2_3:
    lw      a0, -12(s0)
    lui     a1, 419430
    addi    a1, a1, 1639
    mulh    a1, a0, a1
    srli    a2, a1, 31
    srli    a1, a1, 2
    add     a1, a1, a2
    slli    a2, a1, 1
    slli    a1, a1, 3
    add     a1, a1, a2
    sub     a0, a0, a1
    addi    a0, a0, 48
    lw      a1, -16(s0)
    lw      a2, -20(s0)
    addi    a3, a2, 1
    sw      a3, -20(s0)
    add     a1, a1, a2
    sb      a0, 0(a1)
    j       .LBB2_4
.LBB2_4:
    lw      a0, -12(s0)
    lui     a1, 419430
    addi    a1, a1, 1639
    mulh    a0, a0, a1
    srli    a1, a0, 31
    srai    a0, a0, 2
    add     a1, a1, a0
    sw      a1, -12(s0)
    li      a0, 0
    blt     a0, a1, .LBB2_3
    j       .LBB2_5
.LBB2_5:
    lw      a0, -24(s0)
    bgez    a0, .LBB2_7
    j       .LBB2_6
.LBB2_6:
    lw      a0, -16(s0)
    lw      a1, -20(s0)
    addi    a2, a1, 1
    sw      a2, -20(s0)
    add     a1, a1, a0
    li      a0, 45
    sb      a0, 0(a1)
    j       .LBB2_7
.LBB2_7:
    lw      a0, -16(s0)
    lw      a1, -20(s0)
    add     a1, a1, a0
    li      a0, 0
    sb      a0, 0(a1)
    lw      a0, -16(s0)
    call    reverse
    lw      ra, 28(sp)
    lw      s0, 24(sp)
    addi    sp, sp, 32
    ret

# start

_start:
    li t0, 0
    li t6, 100
.L_loop:
    addi sp, sp, -16

    mv a0, t0
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
    addi t0, t0, 1
    blt t0, t6, .L_loop

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
