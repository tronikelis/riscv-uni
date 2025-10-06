void arr_reverse(char *buf, int len) {
  for (int i = 0; i < len / 2; i++) {
    int j = len - 1 - i;
    int temp = buf[i];
    buf[i] = buf[j];
    buf[j] = temp;
  }
}

int strlen(char *ch) {
  int i = 0;
  while (*(ch + i) != '\0') {
    i++;
  }
  return i;
}

void itoa(int num, char *buf) {
  int i = 0;
  do {
    buf[i] = 48 + num % 10;
    num /= 10;
    i++;
  } while (num != 0);

  buf[i] = '\0';

  arr_reverse(buf, i);
}
