#lang racket/base

(provide
 (struct-out hint)
 (except-out (struct-out concretize) concretize)
 (except-out (struct-out concretize-or-overapproximate) concretize-or-overapproximate)
 (except-out (struct-out overapproximate) overapproximate)
 (except-out (struct-out overapproximate-pc) overapproximate-pc)
 (except-out (struct-out case-split) case-split)
 (rename-out
  [concretize-or-overapproximate# concretize-or-overapproximate]
  [concretize# concretize]
  [overapproximate# overapproximate]
  [overapproximate-pc# overapproximate-pc]
  [case-split# case-split]))

(struct hint ())

(struct concretize hint (lens piecewise use-pc))

(define (concretize# lens #:piecewise [piecewise #f] #:use-pc [use-pc #f])
  (concretize lens piecewise use-pc))

(struct concretize-or-overapproximate hint (lens piecewise use-pc))

(define (concretize-or-overapproximate# lens #:piecewise [piecewise #f] #:use-pc [use-pc #f])
  (concretize-or-overapproximate lens piecewise use-pc))

(struct overapproximate hint (lens))

(define (overapproximate# lens)
  (overapproximate lens))

(struct overapproximate-pc hint (pc))

(define (overapproximate-pc# pc)
  (overapproximate-pc pc))

(struct case-split hint (splits))

(define (case-split# splits)
  (case-split splits))
