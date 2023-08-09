#lang rosette/safe

(require
 "common/biriscv.rkt"
 chroniton)

(define state (initialize "software/mul64/64bit.mem"))

(verify-timing state step done?)
