#define CONTROL_REGISTER  0xBBBB0000
#define OPERAND1 (CONTROL_REGISTER + 0x08)
#define OPERAND2 (CONTROL_REGISTER + 0x28)
#define RESULT  (CONTROL_REGISTER + 0x48)

#include <stdio.h>

int checkIfOperationComplete(volatile uint8_t *check)
{
	check = CONTROL_REGISTER;
	
	if((*check & 0x01)==0)
	{
	return 0;
	}
	else
	{
	return 1;
	}

}

void setAddition(volatile uint8_t *check)
{
	check = CONTROL_REGISTER;
	
	*check = (*check & 0x03) |  0x00;
	
	printf("Performing Addition !\n");
}

void setSubtraction(volatile uint8_t *check)
{
	check = CONTROL_REGISTER;
	
	*check = (*check & 0x03)  | 0x04;
	
	
	printf("Performing Subtraction !\n");
}

void setMultiplication(volatile uint8_t *check)
{
	check = CONTROL_REGISTER;
	
	*check  = (*check & 0x03) | 0x08 ;
	
	printf("Performing Multiplication !\n");
}

void setDivision(volatile uint8_t *check)
{
	check = CONTROL_REGISTER;
	
	*check  = (*check & 0x03) | 0x0C;
	
	printf("Performing Division !\n");
}

void fetchResult(volatile uint8_t *check)
{
	check = RESULT;
	
	printf("Result is %d, %d, %d, %d \n", *(check), *(check+0x08), *(check+0x10), *(check+0x18));
}

void putOperand(volatile uint8_t *p, uint8_t array[])
{
	for(int i=0;i<4;i++)
	{
	*p &= 0x00;
	*p |= array[i];
	p = p + 0x08;
	}
}

int main()
{
	// Array of choice
	uint8_t a[4] = {5,6,7,8};
	uint8_t b[4] = {2,3,2,4};
	
	// Putting the array in the peripheral
	volatile uint8_t *p;
	
	p = OPERAND1;
	putOperand(p, a);
	
	p = OPERAND2;
	putOperand(p, b);
	
	// Set Operation to Add
	
	
	
	setAddition(p);
	
	while(checkIfOperationComplete(p)==0)
	{
	}
	
	fetchResult(p);
	
	
	
	// Set Operation to Sub
	
	setSubtraction(p);
	
	while(checkIfOperationComplete(p)==0)
	{
	}
	
	fetchResult(p);
	
	
	// Set Operation to Mul
	
	
	
	setMultiplication(p);
	
	while(checkIfOperationComplete(p)==0)
	{
	}
	
	fetchResult(p);
	
	// Set Operation to Div
	
	
	setDivision(p);
	
	while(checkIfOperationComplete(p)==0)
	{
	}
	
	fetchResult(p);
	
	
	
	printf("Program complete! \n");
	
}
