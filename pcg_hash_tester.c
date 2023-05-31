#include <stdio.h>
#include <stdint.h>
 
unsigned int primes[] = {
    2,   3,  5,  7,
    11, 13, 17, 19,
    23, 29, 31, 37,
    41, 43, 47, 53,
    59, 61, 67, 71,
    73, 79, 83, 89
};

float halton(unsigned int i, unsigned int d) {
    unsigned int b = primes[(d % 24)];

    float f = 1.0f;
    float invB = 1.0f / b;

    float r = 0;

    while (i > 0) {
        f = f * invB;
        r = r + f * (i % b);
        i = i / b;
        break;
    }

    return r;
}

int main(){
    uint32_t div = 4294967295;
    uint32_t max = 0;
    for(u_int64_t i = 0; i < 1000000; i++){
        float ret = halton(i, i * 4);
        printf("%f\n", ret);
    }
    printf("%f", ((double) max / div));
}