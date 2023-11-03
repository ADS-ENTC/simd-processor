#include <stdio.h>

#define UINT8 1
#define UINT32 4

#define MAT_SIZE 4
#define PE_MAT_SIZE 2

#define MEM_ORD_ADDR 3*MAT_SIZE*MAT_SIZE
#define MEM_TMP_ADDR 6*MAT_SIZE*MAT_SIZE
#define PE_COUNT MAT_SIZE/PE_MAT_SIZE
#define MEM_LENGTH MEM_TMP_ADDR+2*PE_COUNT*PE_MAT_SIZE*PE_MAT_SIZE

int main(){

    printf("%d",PE_COUNT);
    return 0;
}
