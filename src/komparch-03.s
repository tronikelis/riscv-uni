# vim:filetype=asmh

.global _start

.section .rodata

str_panic:
    .string "PANIC\n"

str_newline:
    .string "\n"

str_colon_space:
    .string ": "

str_unique_numbers:
    .string "Rasta skirtingu skaitmenu: "

str_unknown_chars:
    .string "Rasta neskaiciu simboliu: "

str_parsed_numbers:
    .string "Surusiuoti skaiciai: "

str_their_frequency:
    .string "Ju pasirodymo daznumas: "

str_open_err:
    .string "cant open file"

str_read_err:
    .string "read file error"

str_get_filename_err:
    .string "get filename error"

.section .bss

.align 16

file_buffer_1024:
    .space 1024

.section .data

freq_arr_40:
    .zero 40

itoa_buffer_32:
    .zero 32

unknown_char_count:
    .word 0

ints_arr:
    .word 0

ints_arr_len:
    .word 0

atoi_buffer_32:
    .zero 32

atoi_buffer_32_len:
    .word 0

.section .text

_start:
    call init_ints_arr

    call get_filename
    bnez a0, L_start_got_filename
    la a0, str_get_filename_err
    call print_str
    la a0, str_newline
    call print_str
    call panic

L_start_got_filename:
    # a0 = char* filename
    call open_filename
    bgez a0, L_read_loop
    la a0, str_open_err
    call print_str
    la a0, str_newline
    call print_str
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

    bltz a0, L_read_loop_err # -1 read error
    beqz a0, L_read_loop_end # 0 eof

    la a0, file_buffer_1024
    mv a1, s2
    call set_frequencies

    la a0, file_buffer_1024
    mv a1, s2
    call parse_buffer

    j L_read_loop_start

L_read_loop_end:
    call sort_parsed_numbers
    call print_parsed_numbers
    call print_unique_numbers

    la a0, str_their_frequency
    call print_str
    la a0, str_newline
    call print_str

    call print_frequencies
    call print_unknown_char_count

    # close(fd)
    mv a0, s1
    call close

    li a0, 0
    call exit

L_read_loop_err:
    la a0, str_read_err
    call print_str
    la a0, str_newline
    call print_str
    call panic

# void ()
sort_parsed_numbers:
    addi sp, sp, -16
    sw ra, 0(sp)

    lw a0, ints_arr
    lw a1, ints_arr_len
    call bubble_sort_int_arr

    lw ra, 0(sp)
    addi sp, sp, 16
    ret

# void ()
print_parsed_numbers:
    addi sp, sp, -16
    sw s1, 4(sp)
    sw ra, 0(sp)

    la a0, str_parsed_numbers
    call print_str
    la a0, str_newline
    call print_str

    # s1 = i
    li s1, -1
L_print_parsed_numbers_loop_start:
    addi s1, s1, 1
    lw t0, ints_arr_len
    bge s1, t0, L_print_parsed_numbers_loop_end

    # a0 = ints_arr[i]
    lw a0, ints_arr
    slli t1, s1, 2
    add a0, a0, t1
    lw a0, 0(a0)

    call print_num
    la a0, str_newline
    call print_str

    j L_print_parsed_numbers_loop_start

L_print_parsed_numbers_loop_end:
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret
    




# void (char* buf, int len)
parse_buffer:
    addi sp, sp, -32
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw ra, 0(sp)

    # s1 = i
    li s1, -1
    # s2 = buf
    mv s2, a0
    # s3 = len
    mv s3, a1
    # s4 = 1: '-', 0: positive
    li s4, 0
L_parse_buffer_loop_start:
    addi s1, s1, 1
    bge s1, s3, L_parse_buffer_loop_end

    # push num if actual num
    add a0, s2, s1
    lbu a0, 0(a0)
    call is_num
    bnez a0, L_parse_buffer_loop_numlike

    # push minus if minus
    add t0, s2, s1
    lbu t0, 0(t0)
    li t1, 45
    beq t0, t1, L_parse_buffer_loop_numlike

    # here we have buf[i] not a number, not a minus
    # if (atoi_buffer_32_len - is_minus <= 0) continue
    lw t0, atoi_buffer_32_len
    # len = len - 1/0
    sub t0, t0, s4
    bgtz t0, L_parse_buffer_loop_push_arr

    # in this path, we have a ['-'] / [] buf
    la t0, atoi_buffer_32_len
    sw zero, 0(t0)
    j L_parse_buffer_loop_start
    
L_parse_buffer_loop_push_arr:
    # append(ints_arr, atoi(atoi_buffer_32, atoi_buffer_32_len))

    la a0, atoi_buffer_32
    lw a1, atoi_buffer_32_len
    call atoi
    call push_int

    la t0, atoi_buffer_32_len
    sw zero, 0(t0)
    j L_parse_buffer_loop_start 

L_parse_buffer_loop_numlike:
    la t0, atoi_buffer_32
    lw t1, atoi_buffer_32_len

    # t3 = buf[i]
    add t3, s2, s1
    lbu t3, 0(t3)

    # s4 = 1/0, based on minus or not minus
    slti s4, t3, 46
    # if (is_minus) atoi_buffer_32_len = 0
    beqz s4, L_parse_buffer_loop_numlike_fin
    li t1, 0

L_parse_buffer_loop_numlike_fin:
    # atoi_buffer_32[atoi_buffer_32_len] = buf[i]
    add t4, t0, t1
    sb t3, 0(t4)

    # atoi_buffer_32_len++
    addi t1, t1, 1
    la t0, atoi_buffer_32_len
    sw t1, 0(t0)

    j L_parse_buffer_loop_start

L_parse_buffer_loop_end:
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 32
    ret



print_unknown_char_count:
    addi sp, sp, -16
    sw ra, 0(sp)

    la a0, str_unknown_chars
    call print_str
    lw a0, unknown_char_count
    call print_num
    la a0, str_newline
    call print_str

    lw ra, 0(sp)
    addi sp, sp, 16
    ret
    

print_unique_numbers:
    # loop through freq array, incrementing counter on non 0 values
    addi sp, sp, -16
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw ra, 0(sp)

    # s1 = i
    li s1, 10
    li s2, 0
L_print_unique_numbers_loop_start:
    addi s1, s1, -1
    bltz s1, L_print_unique_numbers_end

    # index
    la t0, freq_arr_40
    slli t1, s1, 2
    add t0, t1, t0

    lw a0, 0(t0)
    # increment s2, if a0 non zero
    beqz a0, L_print_unique_numbers_loop_start
    
    addi s2, s2, 1

    j L_print_unique_numbers_loop_start
    
L_print_unique_numbers_end:
    la a0, str_unique_numbers
    call print_str
    mv a0, s2
    call print_num
    la a0, str_newline
    call print_str

    lw s2, 8(sp)
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

# void ()
print_frequencies:
    # freq_arr[40], 10 elements of 4 bytes,
    # index -> num, value -> frequency
    addi sp, sp, -16
    sw s1, 4(sp)
    sw ra, 0(sp)


    # s1 = i
    li s1, -1
L_print_frequencies_loop_start:
    addi s1, s1, 1
    li t0, 10
    bge s1, t0, L_print_frequencies_ret

    # [i]: 
    mv a0, s1
    call print_num
    la a0, str_colon_space
    call print_str
    

    # index
    la t0, freq_arr_40
    slli t1, s1, 2
    add t0, t1, t0

    lw a0, 0(t0)
    call print_num
    la a0, str_newline
    call print_str
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

    # skip if '-'
    # t0 = buf + i
    add t0, s3, s1
    # t0 = *t0
    lbu t0, 0(t0)
    li t1, 45
    beq t0, t1, L_set_frequencies_loop_start

    # not a number + not '-' here
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

# (void* addr, int len, int prot, int flags, int fd, int offset)
mmap:
    li a7, 222
    ecall
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

# void (int fd)
close:
    li a7, 57
    ecall
    ret


# void (int status)
exit:
    li a7, 93
    ecall

# void ()
panic:
    la a0, str_panic
    call print_str
    li a0, 1
    call exit

# int (char* string)
strlen:
    li t0, 0

L_strlen_loop_start:
    add t1, a0, t0
    lbu t2, 0(t1)
    # if string[i] != 0
    beqz t2, L_strlen_loop_end

    addi t0, t0, 1
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
# supports negative numbers
itoa:
    addi sp, sp, -16
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw ra, 0(sp)

    # s2 = orig buf
    mv s2, a1
    # s1: s1 1 if -, 0 if +
    sltz s1, a0
    # offset buf by 1 if minus
    add a1, a1, s1
    # jump straight to call if unsigned
    beqz s1, L_itoa_call
    neg a0, a0
L_itoa_call:
    call itoa_unsigned
    beqz s1, L_itoa_ret
    # store '-' at the start of buf
    li t0, 45
    sb t0, 0(s2)
    
L_itoa_ret:
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret


# void (int num, char* buf)
# sets the string representation of num into buf
# does not support minus(-)
itoa_unsigned:
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

L_itoa_unsigned_loop_start:
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
    bgtz s1, L_itoa_unsigned_loop_start
L_itoa_unsigned_loop_end:
    mv a0, s2
    mv a1, s3
    call reverse_char_array
    # buf[i] = 0
    add t0, s2, s3
    sb zero, 0(t0)

    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret


# int (char* buf, int len)
# converts buf to signed integer
# supports negative numbers
atoi:
    addi sp, sp, -16
    sw s1, 4(sp)
    sw ra, 0(sp)

    # s1 = buf[0]
    lbu s1, 0(a0)
    # '-' is 45
    # s1: 0: number, 1: '-'
    slti s1, s1, 46
    # offset buf by 1 if negative
    add a0, a0, s1
    # offset len by -1 if negative
    sub a1, a1, s1
    call atoi_unsigned

    # negate if s1 = 1
    beqz s1, L_atoi_ret
    neg a0, a0

L_atoi_ret:
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret



# int (char* buf, int len)
# converts buf to unsigned integer
atoi_unsigned:
    addi sp, sp, -32
    sw s7, 28(sp)
    sw s6, 24(sp)
    sw s5, 20(sp)
    sw s4, 16(sp)
    sw s3, 12(sp)
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw ra, 0(sp)

    # s1 = buf
    mv s1, a0
    # s2 = len
    mv s2, a1
    # s3 = acc
    li s3, 0
    # s4 = i
    li s4, -1
L_atoi_unsigned_outer_loop_start:
    addi s4, s4, 1
    # if i < len
    bge s4, s2, L_atoi_unsigned_outer_loop_end
    
    # s5/num = buf[i] - '0' (48)
    add s5, s1, s4
    lbu s5, 0(s5)
    addi s5, s5, -48
    # s6/mul = 1
    li s6, 1
    # s7 = j
    li s7, -1
    L_atoi_unsigned_inner_loop_start:
        addi s7, s7, 1
        # if j < len - 1 - i
        addi t0, s2, -1
        sub t0, t0, s4
        bge s7, t0, L_atoi_unsigned_inner_loop_end

        # mul = multiply(mul, 10)
        mv a0, s6
        li a1, 10
        call multiply   
        mv s6, a0
        
        j L_atoi_unsigned_inner_loop_start

L_atoi_unsigned_inner_loop_end:
    # num = multiply(num, mul)
    mv a0, s5
    mv a1, s6
    call multiply
    mv s5, a0
    # acc += num
    add s3, s3, s5

    j L_atoi_unsigned_outer_loop_start

L_atoi_unsigned_outer_loop_end:
    # return acc
    mv a0, s3

    lw s7, 28(sp)
    lw s6, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 32
    ret
    



# void (int num)
print_num:
    addi sp, sp, -16
    sw ra, 0(sp)

    la a1, itoa_buffer_32
    call itoa

    la a0, itoa_buffer_32
    call strlen
    mv t0, a0

    li a0, 1
    la a1, itoa_buffer_32
    mv a2, t0
    call write

    lw ra, 0(sp)
    addi sp, sp, 16
    ret

# void (char* arr, int len)
reverse_char_array:
    # a6 = len/2
    srl a6, a1, 1

    # t0 = i
    li t0, -1
L_reverse_char_array_loop_start:
    addi t0, t0, 1
    # i >= len/2 return
    bge t0, a6, L_reverse_char_array_loop_end

    # t1 = len - i - 1
    sub t1, a1, t0
    addi t1, t1, -1

    # t2 = ptr to i
    # t3 = ptr to j
    add t2, a0, t0
    add t3, a0, t1

    # t4 = i value
    # t5 = j value
    lbu t4, 0(t2)
    lbu t5, 0(t3)

    sb t4, 0(t3)
    sb t5, 0(t2)

    j L_reverse_char_array_loop_start

L_reverse_char_array_loop_end:
    ret
    

init_ints_arr:
    addi sp, sp, -16
    sw ra, 0(sp)

    li a0, 0
    # prepare 1gb of memory
    # this does not actually allocate anything
    # linux will map pages when necessary
    # meaning we have a kinda dynamic array
    li a1, 1
    slli a1, a1, 30
    li a2, 3 # PROT_READ | PROT_WRITE
    li a3, 34 # MAP_ANONYMOUS | MAP_PRIVATE
    li a4, -1 # fd should be -1 on non file maps
    li a5, 0 # offset is ignored
    call mmap
    bgtz a0, L_init_ints_arr_fin
    call panic

L_init_ints_arr_fin:
    la t0, ints_arr
    sw a0, 0(t0)
    # try no segfault
    sw zero, 0(a0)

    lw ra, 0(sp)
    addi sp, sp, 16
    ret

# void (int num)
push_int:
    lw t0, ints_arr
    lw t1, ints_arr_len
    slli t2, t1, 2

    add t3, t0, t2
    sw a0, 0(t3)

    addi t1, t1, 1
    la t0, ints_arr_len
    sw t1, 0(t0)

    ret

# void (int* buf, int len)
bubble_sort_int_arr:
    # if len <= 1 return
    li t0, 1
    bgt a1, t0, L_bubble_sort_int_arr_init
    ret

L_bubble_sort_int_arr_init:
    # t0 = i
    li t0, -1
L_bubble_sort_int_arr_outer_loop_start:
    addi t0, t0, 1
    # t1 = len - 1
    addi t1, a1, -1
    # i < len - 1
    bge t0, t1, L_bubble_sort_int_arr_outer_loop_end

    # t1 = j = i + 1
    mv t1, t0
    L_bubble_sort_int_arr_inner_loop_start:
        addi t1, t1, 1
        # j < len
        bge t1, a1, L_bubble_sort_int_arr_outer_loop_start
        # t3 = buf[i]
        slli t2, t0, 2
        add t2, a0, t2
        lw t3, 0(t2)
        # t5 = buf[j]
        slli t4, t1, 2
        add t4, a0, t4
        lw t5, 0(t4)
        # swap if t3 > t5
        ble t3, t5, L_bubble_sort_int_arr_inner_loop_start
        sw t3, 0(t4)
        sw t5, 0(t2)
        j L_bubble_sort_int_arr_inner_loop_start

L_bubble_sort_int_arr_outer_loop_end:
    ret

# void (char* str)
print_str:
    addi sp, sp, -16
    sw s1, 4(sp)
    sw ra, 0(sp)

    mv s1, a0
    call strlen
    # t0 = int strlen
    mv t0, a0

    li a0, 1
    mv a1, s1
    mv a2, t0
    call write

    lw s1, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

