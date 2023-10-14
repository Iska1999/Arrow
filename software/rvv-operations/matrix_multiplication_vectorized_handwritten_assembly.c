#include <stdio.h>

// Two matrix are multiplied using
// vectorized operations (from a separate
// assembly file), and the
// result is then displayed

extern void sgemm_nn(size_t n, size_t m, size_t k, const int*a, size_t lda, const int*b, size_t ldb, int*c, size_t ldc);

int main()
{
    int sum=0;

    int matrix1[4][4]= {
        {3,2,4,4},
        {5,2,7,6},
        {3,2,5,8},
        {2,1,5,2}
        
    };
    int matrix2[4][4]= {
        {6,7,2,6},
        {2,1,5,2},
        {3,4,6,3},
        {5,2,7,6}
        
    };

    int resultMat[4][4]= {
        {0,0,0,0},
        {0,0,0,0},
        {0,0,0,0},
        {0,0,0,0}
        
    };

    
    sgemm_nn(4, 4, 4, &matrix1[0][0], 4, &matrix2[0][0], 4, &resultMat[0][0], 4);

	return 0;
}
