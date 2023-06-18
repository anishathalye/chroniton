#lang rosette/safe

(require
 "common/otbn.rkt"
 rosutil
 chroniton (prefix-in hint: chroniton/hint))

(define state (initialize "software/x25519/main"))

;; we don't actually need hints, but we use this to show progress
(define (hints focus)
  (define s (frontier-state focus))
  (define c (frontier-cycles focus))
  (eprintf "insn_fetch_resp_addr_q: ~v cycles: ~a~n"
           (get-field s 'otbn.u_otbn_core.u_otbn_instruction_fetch.insn_fetch_resp_addr_q) c)
  (when (> c 20)
    (list
     (hint:concretize (struct-filter-lens "otbn.u_otbn_core.u_otbn_alu_bignum.mod_intg_q"))
     (hint:overapproximate
      (struct-filter-lens
       (field-filter/or 
        "otbn.u_otbn_core.u_otbn_rf_bignum.gen_rf_bignum_ff.u_otbn_rf_bignum_inner.rf"
        "otbn.u_otbn_core.u_otbn_alu_bignum.flags_q"))))))

(verify-timing state step done? #:hints hints)
