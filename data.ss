#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         )

(provide get-feature-requests)

(define (get-feature-requests)
  (load-where #:type 'feature-request
              #:sort-by 'created-at
              #:compare >))
