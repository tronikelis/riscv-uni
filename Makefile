CLANG = clang -target riscv32-unknown-linux-gnu \
	--sysroot=riscv32-toolchain/sysroot \
	--gcc-toolchain=riscv32-toolchain \
	-fuse-ld=lld \
	-fno-builtin \
	-nostdlib \
	src/std.c

STD_C = src/std.c

QEMU = qemu-riscv32 -L riscv32-toolchain/sysroot

.PHONY: all
all: helloworld 01

build/helloworld.o: src/helloworld.s $(STD_C)
	$(CLANG) \
	src/helloworld.s -o build/helloworld.o

build/01.o: src/01.s $(STD_C)
	$(CLANG) \
	src/01.s -o build/01.o

.PHONY: helloworld
helloworld: build/helloworld.o
	$(QEMU) build/helloworld.o

.PHONY: 01
01: build/01.o
	$(QEMU) build/01.o

.PHONY: clean
clean:
	rm -rf build/*
