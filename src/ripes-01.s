.global main

.data

A: 
    .word 6
B: 
    .word 10
C: 
    .word 15

.text

main:
    la s1, A
    lw s1, 0(s1)

    la s2, B
    lw s2, 0(s2)

    la s3, C
    lw s3, 0(s3)

    mv a0, s1
    call push

    mv a0, s2
    call push

    mv a0, s3
    call push
    
    call skaiciuotiFormule
    call spausdintiRezultata
    
    li a7, 93
    li a0, 0
    ecall
    
spausdintiRezultata:
    li a7, 1
    ecall
    ret


skaiciuotiFormule:
    sw ra, -4(sp)

    call pop
    mv t2, a0

    call pop
    mv t1, a0

    call pop
    mv t0, a0
    
    addi sp, sp, -16

    # t0, t1, t2 = a, b, c

    # t0 = a + b ->
    add t0, t0, t1
    # t0 = (a + b) -> * 4
    slli t0, t0, 2
    # t0 = (a + b) * 4 -> + 64
    addi t0, t0, 64
    # t0 = (a + b) * 4 + 64 -> - c
    sub t0, t0, t2

    # t0 = t0 / 2
    srai t0, t0, 1

    mv a0, t0
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

push:
    addi sp, sp, -4
    sw a0, 0(sp)
    ret

pop:
    lw a0, 0(sp)
    addi sp, sp, 4
    ret

