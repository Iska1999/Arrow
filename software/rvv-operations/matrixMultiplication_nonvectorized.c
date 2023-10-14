#include <stdio.h>

// Two matrix are multiplied using
// non-vectorized operations, and the
// result is then displayed

int main()
{
    int sum=0;
    //Matrix of dimensions [m,n] * Matrix of dimensions [n,q] = Matrix of dimensions [m,q]
    int matrix1[4][4]= {
        {3,2,4,4},
        {5,2,7,6},
        {3,2,5,8}
        
    };
    int matrix2[4][4]= {
        {6,7,2,6},
        {2,1,5,2},
        {3,4,6,3}
        
    };

    int product[4][4];
    for (int i=0;i<4;i++) //The end condition of the loop is dependent on the dimensions of the matrix
    {
        for (int j=0;j<4;j++)
        {
            for (int k=0;k<4;k++)
            {
              sum=sum+matrix1[i][k]*matrix2[k][j];
                
            }
            
            product[i][j]=sum;
            sum =0; //reset sum variable to zero
        }
        
        
    }
    for (int i=0;i<4;i++)
    {
        for (int j=0;j<4;j++)
        {
            printf("%d\t", product[i][j]);
        }
        printf("\n");
    }
  
    return 0;
}
