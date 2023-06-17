#include "drivers.h"
#include <stddef.h>

void main() {
    uint64_t *nums = (uint64_t *) FRAM_BASE;
    nums[0] = nums[0] * nums[1];
}
