#include "drivers.h"
#include <stddef.h>

// we can get constant (end-to-end) time behavior by being careful about
// how we pad branch timing

// this program is tuned for the PicoRV32, such that it takes constant time
// (regardless of the "secret" op), even though the code branches on op

void main() {
    uint8_t op = FRAM_BASE[0];
    uint32_t *a = (uint32_t *) (FRAM_BASE + 4);
    uint32_t *b = (uint32_t *) (FRAM_BASE + 8);
    uint32_t *result = (uint32_t *) (FRAM_BASE + 12);

    if (op) {
        *result = *a + *b;
        // following adds 10 cycles of latency on PicoRV32
        asm volatile(
            "beq zero, zero, 0f \n\t"
            "0: \n\t"
        );
    } else {
        *result = *a - *b;
        // following adds 6 cycles of latency on PicoRV32, making the timing
        // match the other branch
        asm volatile("nop");
    }
}
