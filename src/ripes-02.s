# vim:filetype=asmh

.global main

.data

null_string:
    .string "null\n"

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
    li a1, 48
    call prideti_i_prieki

    mv a0, s1
    li a1, 49
    call prideti_i_gala

    mv a0, s1
    call spausdinti_sarasa

    li a7, 93
    li a0, 0
    ecall







# push_front
# struct node { prev: *node, next: *node, data: char }
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
    # early return null alloc
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






# push_back
# struct node { prev: *node, next: *node, data: char }
# a0: *list
# a1: data (char)
prideti_i_gala:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)

    # s1 = *list
    # s2 = data
    mv s1, a0
    mv s2, a1

    call skirti_atminti_mazgui
    bnez a0, L_push_back
    # early return null alloc
    li a0, 0
    j L_push_back_end

L_push_back:
    # a0 = *node

    # init node
    sw zero, 0(a0)
    sw zero, 4(a0)
    sb s2, 8(a0)

    # if non empty tail
    lw t0, 4(s1)
    bnez t0, L_push_back_non_empty_tail
    # empty head / tail
    # list.head = list.tail = *node
    sw a0, 0(s1)
    sw a0, 4(s1)
    j L_push_back_end

L_push_back_non_empty_tail:
    # a0 = *node
    # s1 = *list
    # s2 = data

    # node.prev = list.tail
    lw t0, 4(s1) # t0 = list.tail
    sw t0, 0(a0)
    # list.tail.next = node
    sw a0, 4(t0)
    # list.tail = node
    sw a0, 4(s1)

L_push_back_end:
    lw ra, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 16
    ret

# find_node_index_by_data
# a0: *list
# a1: data
rasti_pagal_reiksme:
    addi sp, sp, -16
    sw ra, 0(sp)

    call find_node_by_data
    mv a0, a1

    lw ra, 0(sp)
    addi sp, sp, 16
    ret




# find_node_by_index
# a0: *list
# a1: index
# returns *node that has a1 index
rasti_pagal_pozicija:
    # if a1 < 0
    bltz, a1, L_find_node_by_index_end
    # t0 = *node
    # t1 = 0
    lw t0, 0(a0)
    li t1, 0
L_find_node_by_index_loop_start:
    # exit if null node
    beqz t0, L_find_node_by_index_end

    # if index == counter
    bne t1, a1, L_find_node_by_index_loop_after
    mv a0, t0
    ret

L_find_node_by_index_loop_after:
    # node = node.next
    lw t0, 4(t0)
    # t1++
    addi t1, t1, 1

    j L_find_node_by_index_loop_start

L_find_node_by_index_end:
    li a0, 0
    ret






# a0: *list
# a1: data
# returns a0(ptr to node), a1(index, -1 if not found)
find_node_by_data:
    # t0 = *node
    # t1 = 0
    lw t0, 0(a0)
    li t1, 0
L_find_by_data_loop_start:
    beqz t0, L_find_by_data_loop_end

    # if t0.data == a1
    lbu t5, 8(t0)
    bne t5, a1, L_find_by_data_loop_after
    mv a0, t0
    mv a1, t1
    ret
L_find_by_data_loop_after:
    # node = node.next
    lw t0, 4(t0)
    # t1++
    addi t1, t1, 1

    j L_find_by_data_loop_start
L_find_by_data_loop_end:
    li a0, 0
    li a1, -1
    ret





# remove_node
# a0: *list
# a1: data (char)
pasalinti_elementa:
    addi sp, sp, -16
    sw s1, 4(sp)
    sw ra, 0(sp)

    # s1 = *list
    mv s1, a0

    call find_node_by_data
    # a0 = *node
    # if a0 == null
    bnez a0, L_remove_node
    j L_remove_node_return

L_remove_node:
    # a0 = *node
    # s1 = *list
    lw t0, 0(s1) # t0 = list.head
    lw t1, 4(s1) # t1 = list.tail

    # if list.head == node
    beq t0, a0, L_remove_node_remove_head
    # if list.tail == node
    beq t1, a0, L_remove_node_remove_tail

L_remove_node_middle:
    # node in middle

    # t5 = node.prev
    # t6 = node.next
    lw t5, 0(a0)
    lw t6, 4(a0)

    # node.prev.next = node.next
    sw t6, 4(t5)
    # node.next.prev = node.prev
    sw t5, 0(t6)

    j L_remove_node_return

L_remove_node_remove_head:
    # already head, check for tail
    beq t1, a0, L_remove_node_remove_single
    # head with next node

    # list.head = list.head.next
    lw t0, 4(t0) # t0 = list.head.next
    sw t0, 0(s1)
    # list.head.prev = null
    sw zero, 0(t0)

    j L_remove_node_return

L_remove_node_remove_tail:
    # already tail, check for head
    beq t0, a0, L_remove_node_remove_single
    # tail with prev node

    # list.tail = list.tail.prev
    lw t1, 0(t1) # t1 = list.tail.prev
    sw t1, 4(s1)
    # list.tail.next = null
    sw zero, 4(t1)

    j L_remove_node_return

L_remove_node_remove_single:
    # head == tail == node
    sw zero, 0(s1)
    sw zero, 4(s1)

L_remove_node_return:
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret





# create_list
# returns struct { head: *node, tail: *node }
saraso_sukurimas:
    addi sp, sp, -16
    sw ra, 0(sp)

    call skirti_atminti_mazgui
    bnez a0, L_create_list
    # early return null alloc
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








# print_list_backwards
# a0: *list
spausdinti_atbulai:
    # t0 = list.tail / node
    lw t0, 4(a0)

    # while t0 != null:
L_print_loop_back_start:
    beqz t0, L_print_loop_back_end

    li a7, 11
    lw a0, 8(t0)
    ecall

    li a7, 4
    la a0, separator
    ecall

    # t0 = t0.prev
    lw t0, 0(t0)
    j L_print_loop_back_start
L_print_loop_back_end:
    li a7, 4
    la a0, null_string
    ecall
    ret

