#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define UINT8 1
#define UINT32 4

#define MAT_SIZE 32
#define PE_MAT_SIZE 8

#define PE_COUNT (MAT_SIZE / PE_MAT_SIZE)

#define MEM8_ORD_ADDR (2 * MAT_SIZE * MAT_SIZE * UINT8)
#define MEM8_LENGTH (4 * MAT_SIZE * MAT_SIZE * UINT8)

#define MEM32_ORD_ADDR (MAT_SIZE * MAT_SIZE * UINT32)
#define MEM32_TMP_ADDR (2 * MAT_SIZE * MAT_SIZE * UINT32)
#define MEM32_LENGTH (MEM32_TMP_ADDR + 2 * PE_COUNT *PE_MAT_SIZE *PE_MAT_SIZE*UINT32)

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
                    mem[target] = mem[source + addr];
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
                    mem[target + addr] = mem[source];
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
            int sum = 0;
            for (int k = 0; k < mat_size; k++)
            {
                sum += mem[m1_ptr + i * mat_size + k] * mem[m2_ptr + k * mat_size + j];
            }
            mem[ans_ptr + i * mat_size + j] = sum;
        }
    }
}

void PE_add(int m1_ptr, int m2_ptr, int ans_ptr, int mat_size)
{
    for (int i = 0; i < mat_size * mat_size; i++)
    {
        mem[ans_ptr + i] = mem[m1_ptr + i] + mem[m2_ptr + i];
    }
}

void Display_mat(int ptr, int mat_size)
{
    for (int i = ptr; i < ptr + mat_size * mat_size; i += mat_size)
    {
        for (int j = i; j < i + mat_size; j++)
        {
            printf("%2u ", mem[j]);
        }
        printf("\n");
    }
    printf("\n");
}

void Display_all(int base, int mat_size)
{
    for (int ptr = base; ptr < MEM8_LENGTH; ptr += mat_size * mat_size)
    {
        Display_mat(ptr, mat_size);
        printf("\n");
    }
}

int get_addr(int i, int j, int base)
{
    return i * PE_MAT_SIZE * MAT_SIZE + j * PE_MAT_SIZE * PE_MAT_SIZE + base;
}

int main()
{
    int mat1_ptr = 0;
    int mat2_ptr = mat1_ptr + MAT_SIZE * MAT_SIZE;
    int matAns_ptr = mat2_ptr + MAT_SIZE * MAT_SIZE;
    int mat1_ord_ptr = MEM8_ORD_ADDR + mat1_ptr;
    int mat2_ord_ptr = MEM8_ORD_ADDR + mat2_ptr;
    int matAns_ord_ptr = MEM8_ORD_ADDR + matAns_ptr;

    for (int i = 0; i < MEM8_LENGTH; i++)
    {
        mem[i] = 0;
    }

    for (int i = 0; i < 2 * MAT_SIZE * MAT_SIZE; i++)
    {
        mem[i] = i + 11;
    }

    order_mat(mat1_ptr, mat1_ord_ptr);
    order_mat(mat2_ptr, mat2_ord_ptr);

    for (int i = 0; i < MAT_SIZE / PE_MAT_SIZE; i++)
    {
        for (int PE_i = 0; PE_i < PE_COUNT; PE_i++)
        {
            int add_addr = MEM8_TMP_ADDR + PE_i * 2 * PE_MAT_SIZE * PE_MAT_SIZE;
            int mul_addr = add_addr + PE_MAT_SIZE * PE_MAT_SIZE;

            // clear add matrix
            for (int k = 0; k < PE_MAT_SIZE * PE_MAT_SIZE; k++)
            {
                mem[add_addr + k] = 0;
            }

            for (int j = 0; j < MAT_SIZE / PE_MAT_SIZE; j++)
            {
                PE_mul(get_addr(i, j, mat1_ord_ptr), get_addr(j, PE_i, mat2_ord_ptr), mul_addr, PE_MAT_SIZE);
                PE_add(add_addr, mul_addr, add_addr, PE_MAT_SIZE);
            }

            int ans_addr = matAns_ord_ptr + get_addr(i, PE_i, 0);
            for (int k = 0; k < PE_MAT_SIZE * PE_MAT_SIZE; k++)
            {
                mem[ans_addr + k] = mem[add_addr + k];
            }
        }
    }

    reorder_mat(matAns_ord_ptr, matAns_ptr);

    Display_mat(matAns_ptr, MAT_SIZE);

    return 0;
}
