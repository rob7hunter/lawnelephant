#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 0)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 5 (= 0)))
         )

(provide
  TAG_REGEXP
  has-tag?
  has-tags?
  )


(define TAG_REGEXP #px"((?<=^)|(?<=[[:blank:]]))#[A-Za-z0-9]+")

;; XXX replace with every at some point
(define (has-all-tags? feat tags)
  (cond
    ((null? tags) #t)
    ((has-tag? feat (car tags)) (has-tags? feat (cdr tags)))
    (else #f)))

(define (has-tag? feat tag)
  (member (string-append "#" tag)
          (regexp-match* TAG_REGEXP (rec-prop feat 'explanation))))
