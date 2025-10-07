void arr_reverse(char* buf, int len) {
    for (int i = 0; i < len / 2; i++) {
        int j = len - 1 - i;
        int temp = buf[i];
        buf[i] = buf[j];
        buf[j] = temp;
    }
}

int strlen(char* ch) {
    int i = 0;
    while (*(ch + i) != '\0') {
        i++;
    }
    return i;
}

void itoa(int num, char* buf) {
    int i = 0;
    do {
        buf[i] = 48 + num % 10;
        num /= 10;
        i++;
    } while (num != 0);

    buf[i] = '\0';

    arr_reverse(buf, i);
}

void print(void* buffer, int len) {
    __asm__("li a7, 64\n"
            "li a0, 1\n"
            "mv a1, %0\n"
            "mv a2, %1\n"
            "ecall\n"
            :
            : "r"(buffer), "r"(len)
            : "a7", "a0", "a1", "a2");
}

void print_reg(int reg) {
    char buffer[32];
    itoa(reg, buffer);

    int len = strlen(buffer);
    buffer[len] = '\n';
    len++;
    print(buffer, len);
}

void print_string(char* str) {
    int len = strlen(str);
    print(str, len);
}

void print_char(char reg) {
    char buffer[1];
    buffer[0] = reg;
    print(buffer, 1);
}
