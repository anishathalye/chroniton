#lang racket/base

(require
 (prefix-in @ (combine-in rosette/safe rosutil))
 "common.rkt"
 "../hardware/ibex/ibex.rkt")

(provide initialize done?
         (all-from-out "../hardware/ibex/ibex.rkt"))

(define (initialize software-path)
  ;; this circuit has some constants (like Verilog initial statements that initialize ROMs)
  ;; extracted as `soc_i`
  (define sym (new-symbolic-hsm_s))
  ;; we extract these using solve
  (define sol (@solve (@assert (hsm_i sym))))
  (define st (@evaluate sym sol))
  ;; all state is symbolic, except the ROM and any state as dictated by hsm_i
  (define initial-state (load-software st 'soc.rom.rom software-path))

  ;; CPU is reset (and will start executing the program)
  (define state
    (with-input
      (step (with-input initial-state (input* 'resetn #f)))
      (input* 'resetn #t)))

  state)

;; hardware/software signals completion by writing #xFF to GPIO output
(define (done? s)
  (@bveq (output-gpio_pin_out (get-output s)) (@bv #xff 8)))
