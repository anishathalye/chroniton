.globl main
main:
  /* set up w8 and w9 to have symbolic values, result will be in w22 */
  li x5, 8
  bn.lid x5++, 64(x0)
  bn.lid x5, 96(x0)
  jal x1, X25519
  li x5, 22
  bn.sid x5, 128(x0)
  ecall
