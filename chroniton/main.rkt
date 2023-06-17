#lang racket/base

(require
 (prefix-in @ (combine-in rosette/safe rosutil))
 racket/list
 yosys/memoize
 (prefix-in hint: "hint.rkt"))

(provide
 (struct-out frontier)
 verify-timing)

(@gc-terms!) ; user will always want this when using Chroniton

(struct frontier (state pc cycles))

(define (verify-timing state step done? #:hints [hints #f])
  (define finished '())
  (define pending (list (frontier state #t 0)))
  (define focus #f)
  ;; DFS
  (let loop ()
    (cond
      ;; focused state: apply hints, check if done, step
      [focus
       ;; apply hints
       (define current-hints (and hints (hints focus)))
       (when (and current-hints (not (void? current-hints)))
         (unless (list? current-hints)
           (set! current-hints (list current-hints)))
         ;; make a list of foci, because we might case-split and then
         ;; apply more hints (which should apply to all splits)
         (define foci (list focus))
         (for ([h current-hints])
           (set! foci (apply-hint foci h)))
         (set! focus (first foci))
         (set! pending (append pending (rest foci))))
       ;; check if done
       ;; want both the `done?` and the `step` in the same memoization context
       (with-memoization-context
         (define is-done (@concretize (done? (frontier-state focus)) (frontier-pc focus)))
         (unless (@concrete? is-done)
           (error 'verify-timing "done? returned non-concrete result, try more case analysis"))
         (cond
           [is-done
            (set! finished (cons focus finished))
            (set! focus #f)
            ;; eagerly check this property
            (check-same-cycles! finished)]
           [else
            ;; step
            (define stepped (step (frontier-state focus)))
            (set! focus (frontier stepped (frontier-pc focus) (add1 (frontier-cycles focus))))]))
       (loop)]
      [(not (empty? pending))
       ;; pull one off the queue
       (set! focus (first pending))
       (set! pending (rest pending))
       (loop)]))
  ;; focus should be #f, pending should be '()
  ;; now, make sure all case splits finished in the same number of cycles
  (check-same-cycles! finished)
  (printf "verified! execution finishes in ~a cycles~n"
          (frontier-cycles (first finished))))

(define (check-same-cycles! list-frontier)
  (unless (empty? list-frontier)
    (define cycles (frontier-cycles (first list-frontier)))
    (for ([f (rest list-frontier)])
      (when (not (equal? (frontier-cycles f) cycles))
        (error 'verify-timing "mismatch in number of cycles on different branches (~a vs ~a)" cycles (frontier-cycles f))))))

(define (apply-hint foci h)
  (apply
   append
   (for/list ([f foci])
     (apply-hint1 f h))))

;; always returns a list
(define (apply-hint1 f h)
  (cond
    [(hint:concretize? h)
     (define effective-pc (if (hint:concretize-use-pc h) (frontier-pc f) #t))
     (define s (@lens-transform
                (hint:concretize-lens h)
                (frontier-state f)
                (lambda (view)
                  (@concretize view effective-pc #:piecewise (hint:concretize-piecewise h)))))
     (list (frontier s (frontier-pc f) (frontier-cycles f)))]
    [(hint:concretize-or-overapproximate? h)
     (define effective-pc (if (hint:concretize-or-overapproximate-use-pc h) (frontier-pc f) #t))
     (define s (@lens-transform
                (hint:concretize-or-overapproximate-lens h)
                (frontier-state f)
                (lambda (view)
                  (@overapproximate-symbolics
                   (@concretize view effective-pc #:piecewise (hint:concretize-or-overapproximate-piecewise h))))))
     (list (frontier s (frontier-pc f) (frontier-cycles f)))]
    [(hint:overapproximate? h)
     (define s (@lens-transform
                (hint:overapproximate-lens h)
                (frontier-state f)
                @overapproximate))
     (list (frontier s (frontier-pc f) (frontier-cycles f)))]
    [(hint:overapproximate-pc? h)
     (define new-pc (hint:overapproximate-pc-pc h))
     (unless (@unsat? (@verify (@assert (@implies (frontier-pc f) new-pc))))
       (error 'verify-timing "failed overapproximate-pc hint (not an overapproximation)"))
     (list (frontier (frontier-state f) new-pc (frontier-cycles f)))]
    [(hint:case-split? h)
     (define splits (hint:case-split-splits h))
     (define pruned-splits
       (filter (lambda (p) (not (@unsat? (@solve (@assert (@&& (frontier-pc f) p)))))) splits))
     (define any-split (apply @|| pruned-splits))
     (unless (@unsat? (@verify (@assert (@implies (frontier-pc f) any-split))))
       (error 'verify-timing "failed case-split hint (failed to prove exhaustiveness)"))
     (for/list ([split pruned-splits])
       (frontier (frontier-state f) split (frontier-cycles f)))]
    [else
     (error 'verify-timing "unimplemented hint: ~a" h)]))
