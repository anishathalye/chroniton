#lang racket/base

(require
 (prefix-in @ (combine-in rosette/safe rosutil))
 "common.rkt"
 "../hardware/otbn/otbn.rkt"
 (only-in racket/base build-list))

(provide initialize done?
         (all-from-out "../hardware/otbn/otbn.rkt"))

(define (initialize software-base)
  ;; this circuit has some constants (like Verilog initial statements that initialize ROMs)
  ;; extracted as `soc_i`
  (define sym (new-symbolic-soc_s))
  ;; we keep things simple here by using complete-solution, so st is
  ;; fully concrete; we will just make the dmem symbolic
  (define sol (@complete-solution (@solve (@assert (soc_i sym))) (@symbolics sym)))
  (define st (@evaluate sym sol))
  (define with-code (load-software st 'otbn.u_imem.u_mem.gen_generic.u_impl_generic.mem (format "~a.text.mem" software-base)))
  ;; read constants
  (define dmem-const (read-mem (format "~a.data.mem" software-base)))
  (define const-length (vector-length dmem-const))
  (define dmem
    (list->vector
     (append
      (vector->list dmem-const)
      (build-list (- (@vector-length (@get-field st 'otbn.u_dmem.u_mem.gen_generic.u_impl_generic.mem))
                     const-length)
                  (lambda (i) (@fresh-symbolic (format "dmem[~a]" (+ i const-length)) (@bitvector 256)))))))
  ;; make rest of data symbolic
  (define state (@update-field with-code 'otbn.u_dmem.u_mem.gen_generic.u_impl_generic.mem dmem))

  ;; reset CPU and give it the start command
  (set! state (with-input state (input* 'resetn #f 'start_cmd (@bv 0 1))))
  (set! state (step state))
  (set! state (with-input state (input* 'resetn #t 'start_cmd (@bv 0 1))))
  (let loop ()
    (define again?
      (if (output-status_idle (get-output state))
          #f
          (set! state (step state))))
    (when again?
      (loop)))
  (set! state (with-input state (input* 'resetn #t 'start_cmd (@bv 1 1))))
  (set! state (step state))
  (set! state (with-input state (input* 'resetn #t 'start_cmd (@bv 0 1))))

  state)

;; outputs when it's idle again
(define (done? s)
  (output-status_idle (get-output s)))
