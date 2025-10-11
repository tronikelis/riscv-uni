STD_C = src/std.c

CLANG = clang -target riscv32-unknown-linux-gnu \
	--sysroot=riscv32-toolchain/sysroot \
	--gcc-toolchain=riscv32-toolchain \
	-fuse-ld=lld \
	-fno-builtin \
	-nostdlib \
	-fno-stack-protector \
	$(STD_C)


QEMU = qemu-riscv32 -L riscv32-toolchain/sysroot

.PHONY: all
all: helloworld 01 02 03

build/helloworld.o: src/helloworld.s $(STD_C)
	$(CLANG) \
	src/helloworld.s -o build/helloworld.o

build/01.o: src/01.s $(STD_C)
	$(CLANG) \
	src/01.s -o build/01.o

build/02.o: src/02.s $(STD_C)
	$(CLANG) \
	src/02.s -o build/02.o

build/03.o: src/03.s $(STD_C)
	$(CLANG) \
	src/03.s -o build/03.o

.PHONY: helloworld
helloworld: build/helloworld.o
	$(QEMU) build/helloworld.o

.PHONY: 01
01: build/01.o
	$(QEMU) build/01.o

.PHONY: 02
02: build/02.o
	$(QEMU) build/02.o "one two three four five"

.PHONY: 03
03: build/03.o
	$(QEMU) build/03.o

.PHONY: clean
clean:
	rm -rf build/*
