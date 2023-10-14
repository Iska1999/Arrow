#include <stdio.h>

// Two matrix are multiplied using 
// vectorized operations (using EPI intrinsics)
// and the result is then displayed  

void mat_mul(long n, long m, long k, const int a[m][k], const int b[k][n], int c[m][n])
{

    int index1,index2,index3=0;
    
    int zeromat[8]={0,0,0,0,0,0,0,0};
    
    for (index1=0;index1<m;index1++)
    {
    for (index2=0;index2<n;index2++)
    {
    __epi_2xi32 vsum = __builtin_epi_vload_2xi32(zeromat, 4);
    
    for (index3=0;index3<k;)
    {
    long gvl = __builtin_epi_vsetvl(k - index3, __epi_e32, __epi_m1);
    __epi_2xi32 va = __builtin_epi_vload_2xi32(a+index1, gvl);
    __epi_2xi32 vb = __builtin_epi_vload_strided_2xi32(*(b)+index2, sizeof(int)*n, gvl);
    __epi_2xi32 vc = __builtin_epi_vmul_2xi32(va, vb, gvl);
    
    vsum = __builtin_epi_vredsum_2xi32(vc, vsum, gvl);
    
    index3 += gvl;
    }
    __builtin_epi_vstore_2xi32(*(c+index1)+index2, vsum, 1);
    }
    }
}



int main()
{

    int a[5][4]= {
        {3,2,4,4},
        {5,2,7,6},
        {3,2,5,8},
        {2,1,5,2},
        {5,2,7,6}
        
    };
    int b[4][6]= {
        {6,7,2,6,2,4},
        {2,1,5,2,4,5},
        {3,4,6,3,6,3},
        {2,1,5,2,3,5}
        
    };
    
    int c[5][6]= {
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0},
        {0,0,0,0,0,0}
        
    };


mat_mul(6,5,4,a,b,c);

    for (int i=0;i<5;i++)
    {
        for (int j=0;j<6;j++)
        {
            printf("%d\t", c[i][j]);
        }
        printf("\n");
    }

printf("\n");
return 0;

}
