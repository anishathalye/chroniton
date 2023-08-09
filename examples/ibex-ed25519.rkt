#lang rosette/safe

(require
 "common/ibex.rkt"
 rosutil
 chroniton)

(define state (initialize "software/ed25519/32bit.mem"))

;; we don't actually need hints, but we use this to show progress
(define (hints focus)
  (define s (frontier-state focus))
  (define c (frontier-cycles focus))
  (eprintf "pc: ~v cycles: ~a~n" (get-field s 'soc.cpu.u_ibex_core.if_stage_i.pc_id_o) c))

(verify-timing state step done? #:hints hints)
