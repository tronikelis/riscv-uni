# riscv-uni

## How to get started with riscv32

Instructions from [gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) for linux riscv32.

Here I am assuming archlinux.

```sh
git clone https://github.com/riscv-collab/riscv-gnu-toolchain
cd riscv-gnu-toolchain

# build deps
sudo pacman -Syu curl python3 libmpc mpfr gmp base-devel texinfo gperf patchutils bc zlib expat libslirp qemu-full clang llvm

# put prefix to a directory which you own
./configure --prefix=/home/user/compilers/riscv32 --with-arch=rv32gc --with-abi=ilp32d

# if your pc can handle, needs >8gb ram, on my laptop linux kills this make process
make -j$(nproc) linux
# for everybody else
make -j4 linux

```

Symlink compiler toolchain to repo directory.

Makefile expects a `riscv32-toolchain` directory at the .git root

```sh
# this assumes configure prefix was ~/compilers/riscv
ln -s ~/compilers/riscv riscv32-toolchain
```

Compile and run

```sh
make
```

Enjoy riscv32
