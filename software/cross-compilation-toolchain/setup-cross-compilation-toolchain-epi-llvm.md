# Cross-Compiling C/C++ to RISC-V with "V" extension support (v0.9, EPI LLVM Fork)

To cross-compile C code to a RISC-V target, we need to following compiler toolchains :

- EPI Fork of the LLVM/Clang Toolchain, which is modified to offer experimental support for RISC-V Vector instructions, as well as vector intrinsics which can be directly called in C code.

- RISC-V GNU Toolchain, which is needed to supplement the missing library/include dependencies in the LLVM/Clang toolchain when cross-compiling.

### Installation Instructions

**Step 1** :

Clone the RISC-V GNU Toolchain, along with its submodules (6.5 GB download) :

	$ git clone --recurse-submodules https://github.com/riscv/riscv-gnu-toolchain

**Step 2** :

Install all standard packages required to build the toolchain.

On Ubuntu, you should run the following commands :

	$ sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

**Step 3** :

Build the Newlib cross-compiler available in the RISC-V GNU Toolchain. You can change the `prefix` argument to your desired installation path :
	
	./configure --prefix=/opt/riscv
	make

Make sure to remember the location of your build folder or save it as an environment variable, as we'll use it later.

**Step 4** :

Clone the EPI fork of the LLVM/Clang toolchain (1.5 GB download) :

	$ git clone https://repo.hca.bsc.es/gitlab/rferrer/llvm-epi.git
	
*Warning* : At the time of writing, the EPI fork supports "V" extension v0.9. In case it moves on to support later iterations of the "V" extensions, please make sure to go through the project's commit history and pull the proper source code.

**Step 5** :

To build the fork of the LLVM/Clang toolchain, we need to install the `ninja` build system. You can find a reference to either build it from source, or download it with your package manager [here](https://github.com/ninja-build/ninja/wiki/Pre-built-Ninja-packages).

**Step 6** :

Before building the fork the LLVM/Clang toolchain, make sure to specify that'd you'd only like to build for RISC-V/X86 target by adding the line ```-DLLVM_TARGETS_TO_BUILD="X86" \``` right after line 261 ```-DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="RISCV" \```. The build process might take a long time :

	$ mkdir build
	$ cd build
	$ ../setup-cmake-llvm-clang debug
	$ make

If you encounter an error related to ```gcc-index``` during the build process, open the file setup-cmake-llvm-clang.sh on the root of the folder, and edit the word `-gdb-index` on line 229 to `--gdb-index` (i.e. add a '-').

**Step 7 (Optional)** :

If you'd like to use the SPIKE simulator to debug RISC-V binaries with Vector Instructions, you must do the following :

Clone the RISC-V Proxy kernel, which can host statically-linked RISC-V ELF binaries, and build it :

	# Clone PK repository
	$ git clone https://github.com/riscv/riscv-pk.git
	
	# Open a terminal in the cloned directory
	$ mkdir build
	$ cd build
	
	# Here, the $RISCV symbol is a variable representing
	# your RISC-V build path
	$ ../configure --prefix=$RISCV
	$ make
	$ make install

Clone the RISC-V SPIKE simulator, install required dependencies, and build it :

	# Clone SPIKE repository
	$ git clone https://github.com/riscv/riscv-isa-sim.git
	
	# Open a terminal in the cloned directory
	$ apt-get install device-tree-compiler
	$ mkdir build
	$ cd build
	
	# Here, the $RISCV symbol is a variable representing
	# your RISC-V build path
	$ ../configure --prefix=$RISCV
	$ make
	$ make install

### Cross-compilation Example

- Reference for C vector intrinsics offered by the LLVM/Clang EPI fork : [Link](https://repo.hca.bsc.es/gitlab/rferrer/epi-builtins-ref/-/blob/master/epi-builtins-ref.md)

- C Code Examples making use of the vector intrinsics : [Link](https://repo.hca.bsc.es/gitlab/rferrer/epi-builtins-ref/-/blob/master/examples.md)

The command line options ```--gcc-toolchain``` and ```---sysroot``` are there to specify additional Includes and Libraries which are present in the RISC-V GNU Toolchain.

- ```--gcc-toolchain=/path/to/risc-v-toolchain-build```
- ```--sysroot=/path/to/risc-v-toolchain-build/riscv64-unknown-elf/lib```

Using the clang binaries in the ```llvm-epi/build/bin``` folder, you can cross-compile C to RISC-V with vector instruction support using the following command :

	$ clang --target=riscv64 -march=rv64gcv0p9 -mepi -menable-experimental-extensions --gcc-toolchain=</path/to/risc-v-toolchain-build> --sysroot=</path/to/risc-v-toolchain-build/riscv64-unknown-elf> <C-Filename> -v -o <Desired-Object-Name>

To check if you have obtained proper RISC-V binaries, you can use the ```file``` command in Linux, or the ```riscv64-unknown-elf-objdump``` binary in the ```risc-v-toolchain-build/bin``` folder :

	$ file <RISC-V-Object-name>
	
	# Or
	
	$ riscv64-unknown-elf-objdump -d <RISC-V-Object-name>

If you'd like to obtain RISC-V assembly from your code, you can use the following command, which contains the ```-S``` argument :
	

	$ clang --target=riscv64 -march=rv64gcv0p9 -mepi -menable-experimental-extensions --gcc-toolchain=</path/to/risc-v-toolchain-build> --sysroot=</path/to/risc-v-toolchain-build/riscv64-unknown-elf> -S <C-Filename> -v 

### Using the SPIKE simulator

If you have followed Step 7 in the installation process, you will have a build of both the RISC-V proxy kernel and the SPIKE simulator. To simulate a RISC-V program atop the proxy kernel, use the following command :

	$ spike pk <RISC-V-Object-name>

More information about SPIKE's interactive debug mode can be found on it's repository [here](https://github.com/riscv/riscv-isa-sim).
