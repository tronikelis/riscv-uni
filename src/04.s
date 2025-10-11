# vim:filetype=asmh

.global _start

.text

_start:
    li s1, 1
    li s2, 10
    # accumulator
    li s3, 0

.L_loop_start:
    bge s1, s2, .L_loop_end
    
    add s3, s3, s1

    addi s1, s1, 1
    j .L_loop_start

.L_loop_end:
    mv a0, s3
    call print_reg

    li a0, 0
    call exit
