# vim:filetype=asmh

.global _start

helloworld:
    .ascii "Hello World\n"

fn_uppercase_char:
    addi sp, sp, -4
    sw s0, 0(sp)

    li s0, 97
    # if a0 < 97; return
    blt a0, s0, .L_fn_uppercase_char_end

    li s0, 122
    # if a0 > 122; return
    bgt a0, s0, .L_fn_uppercase_char_end

    addi a0, a0, -32

.L_fn_uppercase_char_end:
    lw s0, 0(sp)
    addi sp, sp, 4
    ret

_start:
    li t2, 12
    li t1, 0
.L_loop_body:
    addi sp, sp, -2

    la t3, helloworld
    # t3 = helloworld + t4
    add t3, t3, t1

    # t5 = t3[0]
    lb t5, 0(t3)
    mv a0, t5
    call fn_uppercase_char
    mv t5, a0

    # sp[0] = t5
    sb t5, 0(sp)
    # ascii newline
    # t5 = 10
    li t5, 10
    # sp[1] = t5
    sb t5, 1(sp)

    # write(1, sp, 2)
    li a7, 64
    li a0, 1
    mv a1, sp
    li a2, 2
    ecall

    addi sp, sp, 2

    addi t1, t1, 1
    blt t1, t2, .L_loop_body

    # exit
    li a7, 93
    li a0, 0
    ecall
