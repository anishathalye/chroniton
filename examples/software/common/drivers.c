#include "drivers.h"

void gpio_write(uint8_t x) {
    GPIO->out = x;
}

uint8_t gpio_read() {
    return GPIO->in;
}
