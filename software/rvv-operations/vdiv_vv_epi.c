#include <stdio.h>

// Example of a vector division using the EPI intrinsic
// to involve RVV operations
                        
void vec_div(long N, int *c, int *a, int *b) {
  long i;
  for (i = 0; i < N;) {
    long gvl = __builtin_epi_vsetvl(N - i, __epi_e32, __epi_m1);
    __epi_2xi32 va = __builtin_epi_vload_2xi32(&a[i], gvl);
    __epi_2xi32 vb = __builtin_epi_vload_2xi32(&b[i], gvl);
    __epi_2xi32 vc = __builtin_epi_vdiv_2xi32(va, vb, gvl);
    __builtin_epi_vstore_2xi32(&c[i], vc, gvl);
    i += gvl;
  }
}


int main()
{

int a[10] = {10,10,10,10,10,10,10,10,10,10};
int b[10] = {1,2,4,5,5,4,2,1,3,3};
int c[10] = {0,0,0,0,0,0,0,0,0,0};
vec_div(10, c, a, b);

for (int i=0; i<10 ; i++)
{
printf("%d ", c[i]);
}

printf("\n");
return 0;

}
