#include "drivers.h"
#include "ed25519/ed25519.h"
#include <stddef.h>

#define MSG_SIZE 100

uint8_t sig[64];

uint8_t *args = (uint8_t *) FRAM_BASE; /* [pk, sk, msg] */
uint8_t *result = (uint8_t *) FRAM_BASE; /* write back result to same location */

void main() {
    uint8_t *pk = args;
    uint8_t *sk = args+32;
    uint8_t *msg = args+96;
    ed25519_sign(sig, msg, MSG_SIZE, pk, sk);
    for (int i = 0; i < sizeof(sig); i++) {
        result[i] = sig[i];
    }
}
