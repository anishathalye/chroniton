#lang rosette/safe

(require
 "common/ibex.rkt"
 rosutil chroniton racket/match
 (prefix-in hint: chroniton/hint)
 (only-in rosette/base/core/polymorphic ite))

(define state (initialize "software/branch-padding/32bit.mem"))

(define (hints focus)
  (define s (frontier-state focus))
  (define c (frontier-cycles focus))
  (eprintf "pc: ~v cycles: ~a~n" (get-field s 'soc.cpu.u_ibex_core.if_stage_i.pc_id_o) c)
  ;; when processor branches, case split on the branch condition
  (define pc (get-field s 'soc.cpu.u_ibex_core.if_stage_i.pc_id_o))
  (match pc
    [(expression (== ite) c _ _)
     (eprintf "case splitting on ~v~n" c)
     (list
      (hint:case-split (list c (! c)))
      (hint:concretize (lens "soc.cpu.") #:piecewise #t #:use-pc #t))]
    [_ #f]))

(verify-timing state step done? #:hints hints)
