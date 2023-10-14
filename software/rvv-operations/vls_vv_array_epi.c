#include <stdio.h>

// Example of a vector strided-load using the EPI intrinsic
// to load some elements of an array, in place them in another array
                        
void vec_loadStrided(long N, long stride, int *c, int *a) {
    __epi_2xi32 va = __builtin_epi_vload_strided_2xi32(&a[0], stride, N);
    __builtin_epi_vstore_2xi32(&c[0], va, N);
}


int main()
{

int a[19] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19};
int c[4] = {0,0,0,0};
vec_loadStrided(3, 4 ,c, a);

for (int i=0; i<3 ; i++)
{
printf("%d ", c[i]);
}

printf("\n");
return 0;

}
