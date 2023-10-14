#include <stdio.h>

// This file shows how to call
// in-line RISC-V "V" assembly in C code

static inline int foo() 
{ 

	asm volatile(
"vsll.vi v24, v16, 8\n\t"
"vsrl.vi v16, v16, 4 \n\t"
"slli a3, a3, 1 \n\t"
);

    return 2; 
} 

int main()
{
    int test;
    test = foo();
    return 0;
}



