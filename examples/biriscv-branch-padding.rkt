#lang rosette/safe

(require
 "biriscv.rkt"
 rosutil chroniton racket/match
 (prefix-in hint: chroniton/hint)
 (only-in rosette/base/core/polymorphic ite))

(define state (initialize "software/branch-padding/biriscv.mem"))

(define (hints focus)
  (define s (frontier-state focus))
  (define c (frontier-cycles focus))
  (eprintf "pc: ~v cycles: ~a~n" (get-field s 'u_dut.u_exec0.pc_x_q) c)
  ;; when processor branches, case split on the branch condition
  (define pc (get-field s 'u_dut.u_exec0.pc_x_q))
  (match pc
    [(expression (== ite) c _ _)
     (eprintf "case splitting on ~v~n" c)
     (list
      (hint:case-split (list c (! c)))
      (hint:concretize (lens "u_dut.") #:piecewise #t #:use-pc #t))]
    [_ #f]))

(verify-timing state step done? #:hints hints)
