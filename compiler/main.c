#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define INS_SIZE 4096
#define ADDR_WIDTH 8
#define OPCODE_WIDTH 4

enum Opcode
{
    NOP,
    FETCH_A,
    FETCH_B,
    ADD,
    SUB,
    MUL,
    DOT,
    STORE_TMP_I,
    STORE_TMP_F,
    STORE,
    STOP
};

uint16_t ins[INS_SIZE];

uint16_t op_mat_mul(int M, int N, int P, int W)
{
    uint16_t pc = 0;
    ins[pc++] = NOP;

    for (int m = 0; m < M; m++)
    {
        for (int p = 0; p < P; p += W)
        {
            for (int w = 0; w < W; w++)
            {
                for (int n = 0; n < N / W; n++)
                {
                    ins[pc++] = m * N / W + n << OPCODE_WIDTH | FETCH_A;
                    ins[pc++] = (p + w) * N / W + n << OPCODE_WIDTH | FETCH_B;
                    ins[pc++] = DOT;
                }
                ins[pc++] = STORE_TMP_F;
            }
            ins[pc++] = m * P / W + p / W << OPCODE_WIDTH | STORE;
        }
    }
    ins[pc++] = STOP;
    uint16_t count = 2 + M * (P / W) * (1 + W * (1 + 3 * N / W));
    printf("count = %d\n", count);
    printf("pc = %d\n", pc);
    return pc;
}

uint16_t op_elem(int op,int M, int N, int W)
{
    uint16_t pc = 0;
    uint16_t addr;
    ins[pc++] = NOP;

    for (int m = 0; m < M; m++)
    {
        for (int n = 0; n < N; n+=W)
        {
            addr = m * N / W + n / W << OPCODE_WIDTH;
            ins[pc++] = addr | FETCH_A;
            ins[pc++] = addr | FETCH_B;
            ins[pc++] = op;
            ins[pc++] = STORE_TMP_I;
            ins[pc++] = addr | STORE;
        }
    }
    ins[pc++] = STOP;
    return pc;
}

void write_to_file(const char *filepath, const uint16_t *ins, int size)
{
    FILE *file = fopen(filepath, "w");
    if (file == NULL)
    {
        printf("Failed to open file for writing.\n");
        return;
    }

    for (int i = 0; i < size; i++)
    {
        for (int j = ADDR_WIDTH + OPCODE_WIDTH - 1; j >= 0; j--)
            fprintf(file, "%s", (ins[i] & (1 << j)) ? "1" : "0");
        fprintf(file, "\n");
    }

    fclose(file);
}

int main()
{
    // Your existing code here...
    uint16_t pc = op_mat_mul(8, 8, 8, 4);
    // uint16_t pc = op_elem(ADD, 8, 8, 4);

    // Write ins array to a file
    // write_to_file("./cmds/MATMUL_4x4_4x4_2.binc.txt", ins, pc);
    // write_to_file("./cmds/ADD_8x8_4.binc.txt", ins, pc);

    return 0;
}


//formulas
//2+M*(P/W)*(1+W*(1+3*N/W))
//2+M*(P/4)*(1+4*(1+3*N/4))
//2+N*(N/4)*(1+4*(1+3*N/4))

