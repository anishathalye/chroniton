#lang racket/base

(require
 (prefix-in @ (combine-in rosette/safe rosutil))
 "common.rkt"
 "../hardware/biriscv/biriscv.rkt")

(provide initialize done?
         (all-from-out "../hardware/biriscv/biriscv.rkt"))

(define (initialize software-path)
  ;; all state is symbolic, except the ROM
  (define initial-state (load-software (new-symbolic-biriscv_s) 'u_mem.u_rom.ram software-path))

  ;; CPU is reset (and will start executing the program)
  (define state
    (with-input
      (step (with-input initial-state (input* 'rst #t)))
      (input* 'resetn #f)))

  state)

;; hardware/software signals completion by writing #xFF to GPIO output
(define (done? s)
  (@bveq (output-gpio_pin_out (get-output s)) (@bv #xff 8)))
