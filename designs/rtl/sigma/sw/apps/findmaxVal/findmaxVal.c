#define IO_LED (*(volatile unsigned int *)(0x80000000))
#define IO_SW (*(volatile unsigned int *)(0x80000004))
#define ARR_SIZE 16
// #include "stdio.h"
typedef struct
{
    unsigned int max_elem;
    unsigned int max_index;
} maxval_data_t;

// wrapper for instruction activating custom coprocessor
inline unsigned int custom0_instr_wrapper (unsigned int a, unsigned int b)
{
    unsigned int result;
    asm volatile (".insn r 0x0b, 0x0, 0x0, %0, %1, %2"
        : "=r" (result)
        : "r" (a), "r" (b));
    return result;
}

maxval_data_t FindMaxVal(unsigned int x[ARR_SIZE])
{
    maxval_data_t ret_data;
    ret_data.max_elem = 0;
    ret_data.max_index = 0;

    // for (int i = 0; i < ARR_SIZE; i = i + 2)
    // {
    //     // custom coprocessor request
    //     ret_data.max_index = custom0_instr_wrapper(x[i], x[i + 1]);
    // }
    ret_data.max_index = custom0_instr_wrapper(x[0], x[1]);
    ret_data.max_index = custom0_instr_wrapper(x[2], x[3]);
    ret_data.max_index = custom0_instr_wrapper(x[4], x[5]);
    ret_data.max_index = custom0_instr_wrapper(x[6], x[7]);
    ret_data.max_index = custom0_instr_wrapper(x[8], x[9]);
    ret_data.max_index = custom0_instr_wrapper(x[10], x[11]);
    ret_data.max_index = custom0_instr_wrapper(x[12], x[13]);
    ret_data.max_index = custom0_instr_wrapper(x[14], x[15]);
    ret_data.max_elem = x[ret_data.max_index];

    // for (int i = 0; i < ARR_SIZE; i++)
    // {
    //     if (x[i] > ret_data.max_elem)
    //     {
    //         ret_data.max_elem = x[i];
    //         ret_data.max_index = i;
    //     }
    // }
    return ret_data;
}
// Main
int main(int argc, char *argv[])
{
    maxval_data_t maxval_data;
    unsigned int datain[16] = {0x112233cc, 0x55aa55aa, 0x01010202, 0x44556677,
                               0x00000003, 0x00000004, 0x00000005, 0x00000006, 0x00000007, 0xdeadbeef, 0xfefe8800,
                               0x23344556, 0x05050505, 0x07070707, 0x99999999, 0xbadc0ffe};
    IO_LED = 0x55aa55aa;
    maxval_data = FindMaxVal(datain);
    // printf("%d %d",maxval_data.max_index, maxval_data.max_elem);
    IO_LED = maxval_data.max_index;
    IO_LED = maxval_data.max_elem;
    while (1)
    {
    }
}