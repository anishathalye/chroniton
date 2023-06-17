.globl main
main:
  /* compute dmem[2] = dmem[0] + dmem[1] */
  li x5, 8 /* use w8 and w9 to hold data */
  bn.lid x5++, 0(x0)
  bn.lid x5, 32(x0)
  bn.add w22, w8, w9 /* store result in w22 */
  li x5, 22
  bn.sid x5, 64(x0)
  ecall
