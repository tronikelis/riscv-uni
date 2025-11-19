void arr_reverse_c(char* buf, int len) {
    for (int i = 0; i < len / 2; i++) {
        int j = len - 1 - i;
        int temp = buf[i];
        buf[i] = buf[j];
        buf[j] = temp;
    }
}

int strlen_c(char* ch) {
    int i = 0;
    while (*(ch + i) != '\0') {
        i++;
    }
    return i;
}

void itoa_c(int num, char* buf) {
    int i = 0;
    do {
        buf[i] = 48 + num % 10;
        num /= 10;
        i++;
    } while (num != 0);

    buf[i] = '\0';

    arr_reverse_c(buf, i);
}

void print_c(void* buffer, int len) {
    __asm__("li a7, 64\n"
            "li a0, 1\n"
            "mv a1, %0\n"
            "mv a2, %1\n"
            "ecall\n"
            :
            : "r"(buffer), "r"(len)
            : "a7", "a0", "a1", "a2");
}

void print_reg_c(int reg) {
    char buffer[32];
    itoa_c(reg, buffer);

    int len = strlen_c(buffer);
    buffer[len] = '\n';
    len++;
    print_c(buffer, len);
}

void print_string_c(char* str) {
    int len = strlen_c(str);
    print_c(str, len);
}

void print_char_c(char reg) {
    char buffer[1];
    buffer[0] = reg;
    print_c(buffer, 1);
}

void exit_c(int status) {
    __asm__("li a7, 93\n"
            "mv a0, %0\n"
            "ecall\n"
            :
            : "r"(status)
            : "a7", "a0");
    for (;;) {
    }
}
