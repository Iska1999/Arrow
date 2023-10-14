#include <stdio.h>

// Example of a vector elements-summation using the EPI intrinsic
// to involve RVV operations
                        
void vec_sum(long N, int *a, int *b, int *c) {
  long i;
  for (i = 0; i < N;) {
    long gvl = __builtin_epi_vsetvl(N - i, __epi_e32, __epi_m1);
    __epi_2xi32 va = __builtin_epi_vload_2xi32(&a[0], gvl);
    __epi_2xi32 vb = __builtin_epi_vload_2xi32(&b[i], gvl);
    va = __builtin_epi_vredsum_2xi32(vb, va, gvl);
    i += gvl;
    gvl = __builtin_epi_vsetvl(1, __epi_e32, __epi_m1);
    __builtin_epi_vstore_2xi32(&a[0], va, 1);
    
  }
  
  
}


int main()
{

int a[10] = {0,0,0,0,0,0,0,0,0,0};
int b[10] = {5,10,5,10,5,10,5,10,5,10};
int c[10] = {0,0,0,0,0,0,0,0,0,0};
vec_sum(10, a, b,c);


for (int i=0; i<10 ; i++)
{
printf("%d ", a[i]);
}

printf("\n");
return 0;

}
