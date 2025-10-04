# vim:filetype=asmh

.global _start

helloworld:
    .ascii "hello world\n"

_start:
    li t2, 12
    li t1, 0
L_loop_body:
    addi sp, sp, -2

    la t3, helloworld
    # t3 = helloworld + t4
    add t3, t3, t1

    # t5 = t3[0]
    lb t5, 0(t3)
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
    addi a1, sp, 0
    li a2, 2
    ecall

    addi sp, sp, 2

    addi t1, t1, 1
    blt t1, t2, L_loop_body

    # exit
    li a7, 93
    li a0, 0
    ecall
