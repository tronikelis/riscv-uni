CLANG = clang -target riscv32-unknown-linux-gnu \
	--sysroot=riscv32-toolchain/sysroot \
	--gcc-toolchain=riscv32-toolchain \
	-fuse-ld=lld \
	-nostdlib

QEMU = qemu-riscv32 -L riscv32-toolchain/sysroot

.PHONY: all
all: helloworld 01

build/helloworld.o: helloworld/main.s
	$(CLANG) \
	helloworld/main.s -o build/helloworld.o

build/01.o: 01/main.s
	$(CLANG) \
	01/main.s -o build/01.o

.PHONY: helloworld
helloworld: build/helloworld.o
	$(QEMU) build/helloworld.o

.PHONY: 01
01: build/01.o
	$(QEMU) build/01.o

.PHONY: clean
clean:
	rm -rf build/*
