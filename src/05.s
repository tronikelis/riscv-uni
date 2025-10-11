# vim:filetype=asmh

.global _start

.text

fn_print_even:
    addi sp, sp, -16
    sw ra, 0(sp)

    andi t0, a0, 1 
    # t0 != 0
    bnez t0, .L_fn_print_even_end
    call print_reg

.L_fn_print_even_end:
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

_start:
    li s1, 2
    li s2, 20

.L_loop_start:
    bge s1, s2, .L_loop_end

    mv a0, s1
    call fn_print_even

    addi s1, s1, 1
    j .L_loop_start
    
.L_loop_end:
    li a0, 0
    call exit
