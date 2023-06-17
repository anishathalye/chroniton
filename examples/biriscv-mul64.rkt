#lang rosette/safe

(require
 "biriscv.rkt"
 chroniton)

(define state (initialize "software/mul64/biriscv.mem"))

(verify-timing state step done?)
