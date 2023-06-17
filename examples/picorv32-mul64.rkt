#lang rosette/safe

(require
 "picorv32.rkt"
 chroniton)

(define state (initialize "software/mul64/picorv32.mem"))

(verify-timing state step done?)
