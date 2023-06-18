#lang rosette/safe

(require
 "common/picorv32.rkt"
 rosutil chroniton racket/match
 (prefix-in hint: chroniton/hint)
 (only-in rosette/base/core/polymorphic ite))

(define state (initialize "software/branch-padding/picorv32.mem"))

(define (hints focus)
  (define s (frontier-state focus))
  (define c (frontier-cycles focus))
  (eprintf "pc: ~v cycles: ~a~n" (get-field s 'soc.cpu.reg_pc) c)
  ;; when processor branches, case split on the branch condition
  (define pc (get-field s 'soc.cpu.reg_pc))
  (match pc
    [(expression (== ite) c _ _)
     (eprintf "case splitting on ~v~n" c)
     (list
      (hint:case-split (list c (! c)))
      (hint:concretize (lens "soc.cpu.") #:piecewise #t #:use-pc #t))]
    [_ #f]))

(verify-timing state step done? #:hints hints)
