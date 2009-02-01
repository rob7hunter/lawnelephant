#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         "social.ss"
         )

(provide get-feature-requests)

(define (get-feature-requests)
  (load-where #:type 'feature-request
              #:sort-by vote-score
              #:compare >))
