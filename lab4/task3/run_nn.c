/*
 *
 *
 *
 *
 *
 *
 * WARNING
 *
 *
 * Much of this code has been modified from it's prior version.
 *
 * The prior version (visible in git history) was tested. This version has not been tested.
 *
 *
 *
 *
 *
 *
 */




#define L1_IN  784
#define L1_OUT 1000
#define L2_IN L1_OUT
#define L2_OUT 1000
#define L3_IN L2_OUT
#define L3_OUT 10
#define NPARAMS (L1_OUT + L1_IN * L1_OUT + L2_OUT + L2_IN * L2_OUT + L3_OUT + L3_IN * L3_OUT)

volatile unsigned *hex = (volatile unsigned *) 0x00001010; /* hex display PIO */
volatile unsigned *wordcpy_acc = (volatile unsigned *) 0x00001040; /* memory copy accelerator */
volatile unsigned *dot_acc     = (volatile unsigned *) 0x00001100; /* DOT product accelerator */
volatile unsigned *act_acc     = (volatile unsigned *) 0x00001200; /* DOT product + activation function accelerator */
volatile      int *bank0       = (volatile      int *) 0x00006000; /* SRAM bank0 */
volatile      int *bank1       = (volatile      int *) 0x00007000; /* SRAM bank1 */

/* normally these would be contiguous but it's nice to know where they are for debugging */
volatile int *nn      = (volatile int *) 0x0a000000; /* neural network biases and weights */
volatile int *input   = (volatile int *) 0x0a800000; /* input image */
volatile int *l1_acts = (volatile int *) 0x0a801000; /* activations of layer 1 */
volatile int *l2_acts = (volatile int *) 0x0a802000; /* activations of layer 2 */
volatile int *l3_acts = (volatile int *) 0x0a803000; /* activations of layer 3 (outputs) */

int hex7seg(unsigned d) {
    const unsigned digits[] = { 0x40,  0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78, 0x00, 0x10 };
    return (d < 10) ? digits[d] : 0x3f;
}


/* use our memcpy accelerator; pointers must be word-aligned */
void wordcpy(int *dst, int *src, int n_words)
{
    *(wordcpy_acc + 1) = (unsigned) dst;
    *(wordcpy_acc + 2) = (unsigned) src;
    *(wordcpy_acc + 3) = (unsigned) n_words;
    *wordcpy_acc = 0; /* start */
    *wordcpy_acc; /* make sure the accelerator is finished */
}




// note: at most one of the 3 options below should be 1
// if multiples are set to 1, the topmost takes priority
// if all are set to 0, no accelerator is used (pure software)
#define DO_TASK7 1
#define DO_TASK6 0
#define DO_TASK5 0


// ----------------------------------------------------------------
// Two ways of computing dot product

// use software to compute the dot product of w[i]*ifmap[i]
// BASELINE
int dotprod_sw(int n_in, volatile int *w, volatile int *ifmap)
{
        int sum = 0;
        for (unsigned i = 0; i < n_in; ++i) { /* Q16 dot product */
            sum += (int) (((long long) w[i] * (long long) ifmap[i]) >> 16);
        }
        return sum;
}

// TASK5, TASK6
// use accelerator hardware to compute the dot product of w[i]*ifmap[i]
// this hardware must do the equivalent of function dotprod_sw()
int dotprod_hw(int n_in, volatile int *w, volatile int *ifmap)
{
    // computes using hardware for both task5 or task6
    // task5 uses DRAM
    // task6 uses on-chip SRAM (bank0, bank1, bank2, bank3)
    *(dot_acc + 2) = (unsigned) w;
    *(dot_acc + 3) = (unsigned) ifmap;
    *(dot_acc + 5) = (unsigned) n_in;
    *dot_acc = 0; /* start */
    return *dot_acc; /* make sure the accelerator is finished */
}



// ----------------------------------------------------------------

// BASELINE, TASK5 and TASK6:  compute dot products
// optionally use accelerator to compute dot product only
void apply_layer_dot(int n_in, int n_out, volatile int *b, volatile int *w, int use_relu, volatile int *ifmap, volatile int *ofmap)
{
    for (unsigned o = 0, wo = 0; o < n_out; ++o, wo += n_in) {
        int sum = b[o]; /* bias for the current output index */
      #if ( DO_TASK5 || DO_TASK6 )
        sum += dotprod_hw( n_in, &w[wo], ifmap );
      #else // BASELINE
        sum += dotprod_sw( n_in, &w[wo], ifmap );
      #endif
        if (use_relu) sum = (sum < 0) ? 0 : sum; /* ReLU activation */
        ofmap[o] = sum;
    }
}

// TASK7: use full accelerator to calculate dot product, bias and ReLU
// use hardware to compute dot product, apply bias, and apply optional activation function
void apply_layer_act(int n_in, int n_out, volatile int *b, volatile int *w, int use_relu, volatile int *ifmap, volatile int *ofmap)
{
    *(act_acc + 3) = (unsigned) ifmap;
    *(act_acc + 5) = (unsigned) n_in;
    *(act_acc + 7) = (unsigned) use_relu;
    for (unsigned o = 0, wo = 0; o < n_out; ++o, wo += n_in) {
        *(act_acc + 1) = (unsigned) (b + o);
        *(act_acc + 2) = (unsigned) (w + wo);
        *(act_acc + 4) = (unsigned) (ofmap + o);
        *act_acc = 0; /* start */
    }
    *act_acc; /* make sure the accelerator is finished */
}



// ----------------------------------------------------------------

int max_index(int n_in, volatile int *ifmap)
{
    int max_sofar = 0;
    for( int i = 1; i < n_in; ++i ) {
        if( ifmap[i] > ifmap[max_sofar] ) max_sofar = i;
    }
    return max_sofar;
}

void copymem( volatile int *dst, volatile int *src, int n_words )
{
#if 1
    // software version of wordcpy()
    for( int i = 0; i < n_words; i++ ) {
        dst[i] = src[i];
    }
#else
    // hardware version of wordcpy()
    wordcpy( dst, src, n_words );
#endif
}




int main()
{
    *hex = 0x3f; /* display - */

    volatile int *l1_b = nn;                    /* layer 1 bias */
    volatile int *l1_w = l1_b + L1_OUT;         /* layer 1 weights */
    volatile int *l2_b = l1_w + L1_IN * L1_OUT; /* layer 2 bias */
    volatile int *l2_w = l2_b + L2_OUT;         /* layer 2 weights */
    volatile int *l3_b = l2_w + L2_IN * L2_OUT; /* layer 3 bias */
    volatile int *l3_w = l3_b + L3_OUT;         /* layer 3 weights */

    int result;

    copymem( bank0, input, L1_IN );
    // write code here to test copymem software versus wordcpy hardware

  #if DO_TASK7
    // use on-chip SRAM (bank0,bank1) for faster performance
    // apply_layer_act() computes the dot product, bias, and the activation function in hardware with faster memory
    apply_layer_act( L1_IN, L1_OUT, l1_b, l1_w, 1,   bank0, bank1   );
    apply_layer_act( L2_IN, L2_OUT, l2_b, l2_w, 1,   bank1, bank0   );
    apply_layer_act( L3_IN, L3_OUT, l3_b, l3_w, 0,   bank0, bank1   );
    result = max_index( L3_OUT, bank1 );

  #elif DO_TASK6
    // use on-chip SRAM (bank0,bank1) for faster performance 
    // apply_layer_dot() computes the dot product for a row, TASK6 is hardware with faster memory
    apply_layer_dot( L1_IN, L1_OUT, l1_b, l1_w, 1,   bank0, bank1   );
    apply_layer_dot( L2_IN, L2_OUT, l2_b, l2_w, 1,   bank1, bank0   );
    apply_layer_dot( L3_IN, L3_OUT, l3_b, l3_w, 0,   bank0, bank1   );
    result = max_index( L3_OUT, bank1 );

  #elif /* DO_TASK5 or baseline */
    // apply_layer_dot() computes the dot product for a row, BASELINE is software, TASK5 is hardware
    apply_layer_dot( L1_IN, L1_OUT, l1_b, l1_w, 1,   input, l1_acts );
    apply_layer_dot( L2_IN, L2_OUT, l2_b, l2_w, 1, l1_acts, l2_acts );
    apply_layer_dot( L3_IN, L3_OUT, l3_b, l3_w, 0, l2_acts, l3_acts );
    result = max_index( L3_OUT, l3_acts );
  #endif

    *hex = hex7seg( result );
    return 0;
}