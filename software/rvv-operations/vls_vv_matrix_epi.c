#include <stdio.h>

// Example of a vector strided-load using the EPI intrinsic
// to load some elements of a matrix, in place them in an array
               
void vec_loadStrided(long N, long stride, int *c, int n, int a[][n]) {
  long i;
  for (i = 0; i < N;) {
        long gvl = __builtin_epi_vsetvl(N - i, __epi_e32, __epi_m1);
    __epi_2xi32 va = __builtin_epi_vload_strided_2xi32((a+i), stride, gvl);
    __builtin_epi_vstore_2xi32(&c[i], va, gvl);
    i += gvl;
  }
  
}

int main()
{

int a[10][4]= {
        {1,10,3,4},
        {2,0,11,0},
        {3,0,0,0},
        {4,0,0,0},
        {5,0,0,0},
        {6,0,0,0},
        {7,0,0,0},
        {8,0,0,0},
        {9,0,0,0},
        {10,0,0,0}};

int c[10] = {0,0,0,0,0,0,0,0,0,0};
vec_loadStrided(10, 16 ,c, 4, a);

for (int i=0; i<10 ; i++)
{
printf("%d ", c[i]);
}

printf("\n");
return 0;

}
