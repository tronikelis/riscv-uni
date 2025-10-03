.PHONY: all
all: helloworld

build/helloworld.o: helloworld/main.s
	clang -target riscv32-unknown-linux-gnu \
	--sysroot=riscv32-toolchain/riscv/sysroot \
	--gcc-toolchain=riscv32-toolchain/riscv \
	-fuse-ld=lld \
	-nostdlib \
	-static \
	helloworld/main.s -o build/helloworld.o

.PHONY: helloworld
helloworld: build/helloworld.o
	qemu-riscv32 -L riscv32-toolchain/riscv/sysroot build/helloworld.o

.PHONY: clean
clean:
	rm -rf build/*
