#lang rosette/safe

(require
 "common/biriscv.rkt"
 rosutil
 chroniton (prefix-in hint: chroniton/hint)
 (only-in racket/string string-contains?)
 (only-in racket/base symbol->string))

(define state (initialize "software/ed25519/biriscv.mem"))


(define (hints focus)
  (define s (frontier-state focus))
  (define c (frontier-cycles focus))
  (eprintf "cycles: ~a exec0.pc_x_q: ~v exec1.pc_x_q: ~v~n"
           c
           (get-field s 'u_dut.u_exec0.pc_x_q)
           (get-field s 'u_dut.u_exec1.pc_x_q))
  (define over '())
  (for/struct ([n v] s)
    (when (string-contains? (symbol->string n) "REGFILE")
      (unless (or (concrete? v) (constant? v))
        ;; don't overapproximate concrete values, and don't
        ;; overapproximate symbolic constants (just creates more garbage)
        (set! over (cons n over)))))
  (define concretize-fields
    (lambda (s)
      (define sym (symbol->string s))
      ;; concretize all CPU state, except regfile (which is not necessary)
      (and (string-contains? sym "u_dut.") (not (string-contains? sym "REGFILE")))))
  (list
   (hint:overapproximate (struct-filter-lens (apply field-filter/or over)))
   (hint:concretize-or-overapproximate (struct-filter-lens concretize-fields) #:piecewise #t)))

(verify-timing state step done? #:hints hints)
