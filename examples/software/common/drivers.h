#ifndef DRIVERS_H
#define DRIVERS_H

#include <stdint.h>

struct gpio {
    volatile uint8_t out;
    volatile uint8_t _pad1[3];
    volatile uint8_t in;
    volatile uint8_t _pad2[3];
};

#define GPIO ((struct gpio *) 0x40000000)

void gpio_write(uint8_t x);

uint8_t gpio_read();

#define FRAM_BASE ((volatile uint8_t *) 0x10000000)

#endif // DRIVERS_H
