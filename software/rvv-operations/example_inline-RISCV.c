#include <stdio.h>

// This file shows how to call
// in-line RISC-V assembly in C code

static inline int foo() 
{ 

	asm volatile(
"lw     t0, 0(x2)\n\t"
"lw     t1, 4(x2)\n\t"
"sw     t1, 0(x2)\n\t"
"sw     t0, 4(x2)\n \t"
"add    t0, t1,    0x4\n \t"
"xor    t0, t1,    0x4\n \t"
"sb    t3, 0(a0)\n \t"
"add    x10, x10, x3\n \t"
);

    return 1; 
} 

int main()
{
    int test;
    test = foo();
    return 0;
}



