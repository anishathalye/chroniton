#lang rosette/safe

(require
 "common/picorv32.rkt"
 rosutil
 chroniton)

(define state (initialize "software/ed25519/picorv32.mem"))

;; we don't actually need hints, but we use this to show progress
(define (hints focus)
  (define s (frontier-state focus))
  (define c (frontier-cycles focus))
  (eprintf "pc: ~v cycles: ~a~n" (get-field s 'soc.cpu.reg_pc) c))

(verify-timing state step done? #:hints hints)
