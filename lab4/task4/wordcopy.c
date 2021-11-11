#include <stdint.h>

volatile unsigned *wordcpy_acc = (volatile unsigned *) 0x00001040; /* memory copy accelerator */
volatile      int *test_src    = (volatile      int *) 0x08030000; /* Test src byte address */
volatile      int *test_dst    = (volatile      int *) 0x08020000; /* Test dst byte address */ 

// 0003061f: 16-bit address where sram instructions is loaded
// 000180d4: 16-bit address for test_src
// 00010015: Equivalent 16-bit address for test_dst

/* use our memcpy accelerator; pointers must be word-aligned */
void wordcpy(volatile int *dst, volatile int *src, int n_words)
{
    *(wordcpy_acc + 1) = (unsigned) dst;
    *(wordcpy_acc + 2) = (unsigned) src;
    *(wordcpy_acc + 3) = (unsigned) n_words;
    *wordcpy_acc = 0; /* start */
    *wordcpy_acc; /* make sure the accelerator is finished */
}

int main()
{
    // Initialize memory at address test_src
    for(int32_t i = 0; i < 100; ++i)
        test_src[i] = i + 1;

    wordcpy(test_dst, test_src, 10);
    return 0;
}