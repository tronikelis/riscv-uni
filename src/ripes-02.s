# vim:filetype=asmh

.global main

.data

null_string:
    .string "null"

separator:
    .string " -> "

heap:
    .zero 96
heap_end:
    .word 0
heap_ptr:
    .word 0


.text

main:
    call saraso_sukurimas
    mv s1, a0
    li a1, 65
    call prideti_i_prieki
    
    mv a0, s1
    call spausdinti_sarasa
    
    li a7, 93
    li a0, 0
    ecall

# struct node { prev: *node, next: *node, data: char }

# push_front
# a0: *list
# a1: data (char)
prideti_i_prieki:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)

    # s1 = *list
    # s2 = data
    mv s1, a0
    mv s2, a1

    call skirti_atminti_mazgui
    bnez a0, L_push_front
    li a0, 0
    j L_push_front_end

L_push_front:
    # a0 = *node

    # init node
    sw zero, 0(a0)
    sw zero, 4(a0)
    sb s2, 8(a0)
    
    # if non empty head
    lw t0, 0(s1)
    bnez t0, L_push_front_non_empty_head
    # empty head / tail
    # list.head = list.tail = *node
    sw a0, 0(s1)
    sw a0, 4(s1)
    j L_push_front_end
    
L_push_front_non_empty_head:
    # a0 = *node
    # s1 = *list
    # s2 = data

    # node.next = list.head
    lw t0, 0(s1) # t0 = list.head
    sw t0, 4(a0)
    # list.head.prev = node
    sw a0, 0(t0) 
    # list.head = node
    sw a0, 0(s1)
    

L_push_front_end:
    lw ra, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 16
    ret




# create_list
# returns struct { head: *node, tail: *node }
saraso_sukurimas:
    addi sp, sp, -16
    sw ra, 0(sp)

    call skirti_atminti_mazgui
    bnez a0, L_create_list
    li a0, 0
    j L_create_list_end

L_create_list:
    # a0 = alloc(12) 
    # struct.0 = 0
    sw zero, 0(a0)
    # struct.1 = 0
    sw zero, 4(a0)

L_create_list_end:
    lw ra, 0(sp)
    addi sp, sp, 16
    ret





# alloc
# returns ptr
skirti_atminti_mazgui:
    # t0 = heap_ptr
    # t1 = &heap_end
    la t0, heap_ptr
    lw t0, 0(t0)
    la t1, heap_end
    
    # first time init heap_ptr to heap
    bnez t0, L_alloc_init
    # heap_ptr = &heap
    la t6, heap
    mv t0, t6

L_alloc_init:
    blt t0, t1, L_alloc_yesyes
    # oom
    li a0, 0
    ret

L_alloc_yesyes:
    # save current ptr
    mv t3, t0

    # mutate global one
    # heap_ptr = heap_ptr + 12
    addi t0, t0, 12
    la t6, heap_ptr
    sw t0, 0(t6)

    mv a0, t3
    ret
    



    

# print_list
# a0: *list
spausdinti_sarasa:
    # t0 = list.head / node
    lw t0, 0(a0)

    # while t0 != null:
L_print_loop_start:
    beqz t0, L_print_loop_end
    
    li a7, 11
    lw a0, 8(t0)
    ecall

    li a7, 4
    la a0, separator
    ecall

    # t0 = t0.next
    lw t0, 4(t0)
    j L_print_loop_start
L_print_loop_end:
    li a7, 4
    la a0, null_string
    ecall
    ret



