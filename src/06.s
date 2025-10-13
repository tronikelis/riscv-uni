# vim:filetype=asmh

.global _start

.data

A: 
    .word 6
B: 
    .word 10
C: 
    .word 15

.text

_start:
    la s1, A
    lw s1, 0(s1)

    la s2, B
    lw s2, 0(s2)

    la s3, C
    lw s3, 0(s3)

    mv a0, s1
    call fn_push

    mv a0, s2
    call fn_push

    mv a0, s3
    call fn_push

    call fn_math
    jal ra, print_reg

    li a0, 0
    addi a0, a0, 0
    call exit

# f(abc) = ((a+b) * 4 + 64 - c) / 2)
fn_math:
    mv s11, ra

    call fn_pop
    mv t2, a0

    call fn_pop
    mv t1, a0

    call fn_pop
    mv t0, a0

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
    mv ra, s11
    jalr zero, 0(ra)

    


    
    
fn_push:
    addi sp, sp, -4
    sw a0, 0(sp)
    ret

fn_pop:
    lw a0, 0(sp)
    addi sp, sp, 4
    ret
