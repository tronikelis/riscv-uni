# vim:filetype=asmh

.global _start

.rodata

panic_msg:
    .string "PANIC\n"

panic_msg_len:
    .int . - panic_msg

.bss

.align 4

file_buffer:
    .space 1024

.data

freq_arr:
    .zero 40

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
    la a1, file_buffer
    li a2, 1024
    call read
    # s2 = how many bytes read
    mv s2, a0
    
    blez a0, L_read_loop_end

    la a0, file_buffer
    mv a1, s2
    call set_frequencies

    
    j L_read_loop_start

L_read_loop_end:

    li a0, 0
    call exit

# void (void* buf, int len)
set_frequencies:
    # loop through the whole buffer
    # try to convert current char to a number
    # if success:
    #   freq_arr[char]++
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
    la t0, freq_arr
    # t1 = a0*4
    slli t1, a0, 2
    # t0 = freq_arr + a0*4
    add t0, t0, t1

    mv a0, t0
    call deref_increment

    j L_set_frequencies_loop_start

L_set_frequencies_minus_one:
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
    la a1, panic_msg
    lw a2, panic_msg_len
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


