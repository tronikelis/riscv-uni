# vim:filetype=asmh

.global _start

.rodata

panic_msg_6:
    .string "PANIC\n"
newline_1:
    .string "\n"
colon_space_2:
    .string ": "

.bss

.align 4

file_buffer_1024:
    .space 1024

.data

freq_arr_40:
    .zero 40

itoa_buffer_32:
    .zero 32

unknown_char_count:
    .word 0

.text

_start:
    call get_filename
    bnez a0, L_start_got_filename
    call panic
L_start_got_filename:
    # a0 = char* filename
    call open_filename
    bgez a0, L_read_loop
    call panic

L_read_loop:
    # s1 = a0 = file descriptor
    mv s1, a0
L_read_loop_start:
    mv a0, s1
    la a1, file_buffer_1024
    li a2, 1024
    call read
    # s2 = how many bytes read
    mv s2, a0

    blez a0, L_read_loop_end

    la a0, file_buffer_1024
    mv a1, s2
    call set_frequencies

    j L_read_loop_start

L_read_loop_end:
    call print_frequencies

    li a0, 0
    call exit

# void ()
print_frequencies:
    # freq_arr[40], 10 elements of 4 bytes,
    # index -> num, value -> frequency
    addi sp, sp, -16
    sw s1, 4(sp)
    sw ra, 0(sp)


    # s1 = i
    li s1, 10
L_print_frequencies_loop_start:
    addi s1, s1, -1
    bltz s1, L_print_frequencies_ret

    # [i]: 
    mv a0, s1
    call print_num
    call print_colon_space
    

    # index
    la t0, freq_arr_40
    slli t1, s1, 2
    add t0, t1, t0

    lw a0, 0(t0)
    call print_num
    call print_newline
    j L_print_frequencies_loop_start

L_print_frequencies_ret:
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret


# void (void* buf, int len)
set_frequencies:
    # loop through the whole buffer
    # try to convert current char to a number
    # if success:
    #   freq_arr[num]++
    # else:
    #   unknown_char_count++

    addi sp, sp, -16
    sw s3, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw ra, 0(sp)


    # s1 = i
    li s1, -1
    # s2 = len
    mv s2, a1
    # s3 = buf
    mv s3, a0
L_set_frequencies_loop_start:
    addi s1, s1, 1

    # if i == len
    beq s1, s2, L_set_frequencies_ret

    # a0 = buf + i
    add a0, s3, s1
    # a0 = *a0
    lbu a0, 0(a0)
    call to_num
    # a0 either -1 -> not a number, or a 0-9 number

    bltz a0, L_set_frequencies_minus_one
    # update freq_arr here and continue
    la t0, freq_arr_40
    # t1 = a0*4
    slli t1, a0, 2
    # t0 = freq_arr + a0*4
    add t0, t0, t1

    mv a0, t0
    call deref_increment

    j L_set_frequencies_loop_start

L_set_frequencies_minus_one:
    # not a number path here
    la a0, unknown_char_count
    call deref_increment
    j L_set_frequencies_loop_start

L_set_frequencies_ret:
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret


# void (int* ptr)
# *ptr++
deref_increment:
    lw t0, 0(a0)
    addi t0, t0, 1
    sw t0, 0(a0)
    ret

# bool (void* register)
is_num:
    li t0, 48
    li t1, 57
    # if a0 < 48 -> return
    blt a0, t0, L_is_num_ret_false
    # if a0 > 57 -> return
    bgt a0, t1, L_is_num_ret_false
    li a0, 1
    ret
L_is_num_ret_false:
    li a0, 0
    ret

# int (void* register)
# returns -1 if input is not a number
to_num:
    addi sp, sp, -16
    sw s1, 4(sp)
    sw ra, 0(sp)

    # s1 = input
    mv s1, a0
    call is_num
    # if a0 == 0
    bnez a0, L_to_num_convert
    li a0, -1
    j L_to_num_ret

L_to_num_convert:
    li t0, 48
    # a0 = input - 48
    sub a0, s1, t0

L_to_num_ret:
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret



# int (char* filename)
open_filename:
    mv a1, a0               # a1 = filename
    li a0, -100             # a0 = dirfd (AT_FDCWD - dabartinė darbo direktorija)
    li a2, 0                # a2 = vėliavėlės (0 = O_RDONLY, tik skaitymui)
    li a3, 0                # a3 = režimas (nenaudojamas su O_RDONLY)
    li a7, 56               # a7 = 'open' sisteminis iškvietimas
    ecall
    ret

# char* ()
get_filename:
    # t0 = argc
    lw t0, 0(sp)
    li t2, 2
    # argc != 2
    beq t0, t2, L_get_filename_2
    li a0, 0
    ret

L_get_filename_2:
    # a0 = argv[1]
    lw a0, 8(sp)
    ret

# int (int fd, void* buf, int len)
read:
    li a7, 63
    ecall
    ret


# int (int fd, void* buf, int len)
write:
    li a7, 64
    ecall
    ret

# void (int status)
exit:
    li a7, 93
    ecall

# void ()
panic:
    li a0, 1
    la a1, panic_msg_6
    li a2, 6
    call write
    li a0, 1
    call exit

# int (char* string)
strlen:
    li t0, 0
    mv t1, a0

L_strlen_loop_start:
    lbu t2, 0(t1)
    # if string[i] != 0
    beqz t2, L_strlen_loop_end

    addi t0, t0, 1
    addi t1, t1, 1
    j L_strlen_loop_start

L_strlen_loop_end:
    mv a0, t0
    ret


# int, int (int a, int b)
# returns result, remainder
divide:
    # t0 = acc
    li t0, 0
    # t1 = count
    li t1, 0

    # while (acc + b <= a)
L_divide_loop_start:
    # t2 = (acc + b)
    add t2, t0, a1
    bgt t2, a0, L_divide_loop_end

    # count++
    addi t1, t1, 1
    # acc += b
    add t0, t0, a1

    j L_divide_loop_start

L_divide_loop_end:
    sub a1, a0, t0
    mv a0, t1
    ret

# int (int a, int b)
multiply:
    # t0 = i
    li t0, -1
    # t1 = acc
    li t1, 0

L_multiply_loop_start:
    addi t0, t0, 1
    bge t0, a1, L_multiply_loop_end

    add t1, t1, a0
    j L_multiply_loop_start

L_multiply_loop_end:
    mv a0, t1
    ret


# void (int num, char* buf)
# sets the string representation of num into buf
itoa:
    addi sp, sp, -16
    sw s3, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw ra, 0(sp)

    # s1 = num
    mv s1, a0
    # s2 = buf
    mv s2, a1
    # s3 = i
    li s3, 0

L_itoa_loop_start:
    # divide(num, 10)
    mv a0, s1
    li a1, 10
    call divide
    # a0 = result
    # a1 = remainder

    # t0 = remainder + '0', this is the character
    add t0, a1, 48

    add t1, s2, s3
    # buf[i++] = character
    sb t0, 0(t1)
    addi s3, s3, 1

    # num = result
    mv s1, a0
    # while (num > 0) jump
    bgtz s1, L_itoa_loop_start
L_itoa_loop_end:
    # buf[i] = 0
    add t0, s2, s3
    sb zero, 0(t0)

    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret


# void (int num)
print_num:
    addi sp, sp, -16
    sw ra, 0(sp)

    la a1, itoa_buffer_32
    call itoa

    li a0, 1
    la a1, itoa_buffer_32
    li a2, 32
    call write

    lw ra, 0(sp)
    addi sp, sp, 16
    ret

print_colon_space:
    addi sp, sp, -16
    sw ra, 0(sp)

    li a0, 1
    la a1, colon_space_2
    li a2, 2
    call write
    
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

# void ()
print_newline:
    addi sp, sp, -16
    sw ra, 0(sp)

    li a0, 1
    la a1, newline_1
    li a2, 1
    call write

    lw ra, 0(sp)
    addi sp, sp, 16
    ret

