#lang rosette/safe

(require
 "common/ibex.rkt"
 chroniton)

(define state (initialize "software/mul64/32bit.mem"))

(verify-timing state step done?)
