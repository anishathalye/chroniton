#lang racket/base

(require (prefix-in @ (combine-in rosette/safe rosutil))
         racket/string)

(provide repeat read-mem load-software)

(define (repeat x n [acc '()])
  (if (zero? n)
      acc
      (repeat x (sub1 n) (cons x acc))))

(define (read-mem path-to-mem [pad-length #f])
  (define data
    (for/fold ([acc '()] #:result (list->vector (reverse acc)))
              ([ln (in-lines (open-input-file path-to-mem))])
      (if (non-empty-string? ln)
          (cons
           (let* ([bitwidth (* (string-length ln) 4)]
                  [hex-str (format "#x~a" ln)]
                  [v (read (open-input-string hex-str))]) ; there's probably a better way to do this
             (@bv v bitwidth))
           acc)
          acc)))
  (if pad-length
      (let ([bitwidth (@bitvector-size (@type-of (@vector-ref data 0)))])
        (list->vector
         (append
          (vector->list data)
          (repeat (@bv 0 bitwidth) (- pad-length (vector-length data))))))
      data))

(define (load-software s rom-name path-to-mem)
  (define v (@get-field s rom-name))
  (define imem (read-mem path-to-mem (@vector-length v)))
  (@update-field s rom-name imem))
