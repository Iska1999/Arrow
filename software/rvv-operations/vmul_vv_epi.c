#include <stdio.h>

// Example of a vector multiplication using the EPI intrinsic
// to involve RVV operations
                        
void vec_mul(long N, int *c, int *a, int *b) {
  long i;
  for (i = 0; i < N;) {
    long gvl = __builtin_epi_vsetvl(N - i, __epi_e32, __epi_m1);
    __epi_2xi32 va = __builtin_epi_vload_2xi32(&a[i], gvl);
    __epi_2xi32 vb = __builtin_epi_vload_2xi32(&b[i], gvl);
    __epi_2xi32 vc = __builtin_epi_vmul_2xi32(va, vb, gvl);
    __builtin_epi_vstore_2xi32(&c[i], vc, gvl);
    i += gvl;
  }
}


int main()
{

int a[10] = {1,0,1,0,1,0,1,0,1,0};
int b[10] = {1,1,2,1,3,1,4,1,5,1};
int c[10] = {0,0,0,0,0,0,0,0,0,0};
vec_mul(10, c, a, b);


for (int i=0; i<10 ; i++)
{
printf("%d ", c[i]);
}

printf("\n");
return 0;

}
