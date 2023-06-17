#lang rosette/safe

(require
 "otbn.rkt"
 rosutil
 chroniton)

(define state (initialize "software/wadd/main"))

;; we don't actually need hints, but we use this to show progress
(define (hints focus)
  (define s (frontier-state focus))
  (define c (frontier-cycles focus))
  (eprintf "dmem[2]: ~v~n" (vector-ref (get-field s 'otbn.u_dmem.u_mem.gen_generic.u_impl_generic.mem) 2))
  (eprintf "insn_fetch_resp_addr_q: ~v cycles: ~a~n"
           (get-field s 'otbn.u_otbn_core.u_otbn_instruction_fetch.insn_fetch_resp_addr_q) c))

(verify-timing state step done? #:hints hints)
