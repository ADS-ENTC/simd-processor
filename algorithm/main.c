#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define MAT_SIZE 32
#define PE_MAT_SIZE 8

#define PE_COUNT (MAT_SIZE / PE_MAT_SIZE)

#define MEM8_ORD_ADDR (2 * MAT_SIZE * MAT_SIZE)
#define MEM8_LENGTH (4 * MAT_SIZE * MAT_SIZE)

#define MEM32_ORD_ADDR (MAT_SIZE * MAT_SIZE)
#define MEM32_TMP_ADDR (2 * MAT_SIZE * MAT_SIZE)
#define MEM32_LENGTH (MEM32_TMP_ADDR + 2 * PE_COUNT * PE_MAT_SIZE * PE_MAT_SIZE)

uint8_t mem8[MEM8_LENGTH];
uint32_t mem32[MEM32_LENGTH];

void order_mat(int source, int target)
{
    for (int i = 0; i < MAT_SIZE / PE_MAT_SIZE; i++)
    {
        for (int j = 0; j < MAT_SIZE / PE_MAT_SIZE; j++)
        {
            int start = i * PE_MAT_SIZE * MAT_SIZE + j * PE_MAT_SIZE;
            for (int k = 0; k < PE_MAT_SIZE; k++)
            {
                for (int l = 0; l < PE_MAT_SIZE; l++)
                {
                    int addr = start + k * MAT_SIZE + l;
                    mem8[target] = mem8[source + addr];
                    target++;
                }
            }
        }
    }
}

void reorder_mat(int source, int target)
{
    for (int i = 0; i < MAT_SIZE / PE_MAT_SIZE; i++)
    {
        for (int j = 0; j < MAT_SIZE / PE_MAT_SIZE; j++)
        {
            int start = i * PE_MAT_SIZE * MAT_SIZE + j * PE_MAT_SIZE;
            for (int k = 0; k < PE_MAT_SIZE; k++)
            {
                for (int l = 0; l < PE_MAT_SIZE; l++)
                {
                    int addr = start + k * MAT_SIZE + l;
                    mem32[target + addr] = mem32[source];
                    source++;
                }
            }
        }
    }
}

void PE_mul(int m1_ptr, int m2_ptr, int ans_ptr, int mat_size)
{
    for (int i = 0; i < mat_size; i++)
    {
        for (int j = 0; j < mat_size; j++)
        {
            uint32_t sum = 0;
            for (int k = 0; k < mat_size; k++)
            {
                sum += mem8[m1_ptr + i * mat_size + k] * mem8[m2_ptr + k * mat_size + j];
            }
            mem32[ans_ptr + i * mat_size + j] = sum;
        }
    }
}

void PE_add(int m1_ptr, int m2_ptr, int ans_ptr, int mat_size)
{
    for (int i = 0; i < mat_size * mat_size; i++)
    {
        mem32[ans_ptr + i] = mem32[m1_ptr + i] + mem32[m2_ptr + i];
    }
}

void Display_mat8(int ptr, int mat_size)
{
    for (int i = ptr; i < ptr + mat_size * mat_size; i += mat_size)
    {
        for (int j = i; j < i + mat_size; j++)
        {
            printf("%2u ", mem8[j]);
        }
        printf("\n");
    }
    printf("\n");
}

void Display_mat32(int ptr, int mat_size)
{
    for (int i = ptr; i < ptr + mat_size * mat_size; i += mat_size)
    {
        for (int j = i; j < i + mat_size; j++)
        {
            printf("%2u ", mem32[j]);
        }
        printf("\n");
    }
    printf("\n");
}

int get_addr(int i, int j, int base)
{
    return i * PE_MAT_SIZE * MAT_SIZE + j * PE_MAT_SIZE * PE_MAT_SIZE + base;
}

int main()
{
    int mat1_ptr = 0;
    int mat2_ptr = mat1_ptr + MAT_SIZE * MAT_SIZE;

    int mat1_ord_ptr = mat2_ptr + MAT_SIZE * MAT_SIZE;
    int mat2_ord_ptr = mat1_ord_ptr + MAT_SIZE * MAT_SIZE;

    int matAns_ptr = 0;
    int matAns_ord_ptr = matAns_ptr + MAT_SIZE * MAT_SIZE;

    for (int i = 0; i < 2 * MAT_SIZE * MAT_SIZE; i++)
    {
        mem8[i] = (i + 11)%255;
    }

    order_mat(mat1_ptr, mat1_ord_ptr);
    order_mat(mat2_ptr, mat2_ord_ptr);

    for (int i = 0; i < MAT_SIZE / PE_MAT_SIZE; i++)
    {
        for (int PE_i = 0; PE_i < PE_COUNT; PE_i++)
        {
            int add_addr = MEM32_TMP_ADDR + PE_i * 2 * PE_MAT_SIZE * PE_MAT_SIZE;
            int mul_addr = add_addr + PE_MAT_SIZE * PE_MAT_SIZE;

            // clear add matrix
            for (int k = 0; k < PE_MAT_SIZE * PE_MAT_SIZE; k++)
            {
                mem32[add_addr + k] = 0;
            }

            for (int j = 0; j < MAT_SIZE / PE_MAT_SIZE; j++)
            {
                PE_mul(get_addr(i, j, mat1_ord_ptr), get_addr(j, PE_i, mat2_ord_ptr), mul_addr, PE_MAT_SIZE);
                PE_add(add_addr, mul_addr, add_addr, PE_MAT_SIZE);
            }

            int ans_addr = matAns_ord_ptr + get_addr(i, PE_i, 0);
            for (int k = 0; k < PE_MAT_SIZE * PE_MAT_SIZE; k++)
            {
                mem32[ans_addr + k] = mem32[add_addr + k];
            }
        }
    }

    reorder_mat(matAns_ord_ptr, matAns_ptr);

    Display_mat32(matAns_ptr, MAT_SIZE);

    return 0;
}
