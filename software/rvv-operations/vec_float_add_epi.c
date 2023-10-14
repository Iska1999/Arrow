#include <stdio.h>

// Example of a vector floating-point addition using the EPI intrinsic
// to involve RVV operations

void vec_add(long N, double *c, double *a, double *b) {
  long i;
  for (i = 0; i < N;) {
    long gvl = __builtin_epi_vsetvl(N - i, __epi_e64, __epi_m1);
    __epi_1xf64 va = __builtin_epi_vload_1xf64(&a[i], gvl);
    __epi_1xf64 vb = __builtin_epi_vload_1xf64(&b[i], gvl);
    __epi_1xf64 vc = __builtin_epi_vfadd_1xf64(va, vb, gvl);
    __builtin_epi_vstore_1xf64(&c[i], vc, gvl);
    i += gvl;
  }
}


int main()
{

double a[8] = {1,1,1,1,1,1,1,1};
double b[8] = {1,1,1,1,1,1,1,1};
double c[8] = {0,0,0,0,0,0,0,0};
vec_add(8, c, a, b);

for (int i=0; i<8 ; i++)
{
printf("%f ", c[i]);
}

printf("\n");
return 0;

}
