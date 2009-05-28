#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 5 (= 1)))
         )

(provide
  TAG_REGEXP
  has-tag?
  has-all-tags?
  gen-tag-list
  post-pre-pop-tag-str
  )

;; copied from data.ss. Can't require data b/c data requires tags! 

(define (get-feature-requests-generic #:restricted-to (filter-fn #f)
                                      #:sort-by (sort-by 'created-at))
  (load-where #:type 'feature-request
              #:sort-by sort-by
              #:compare >
              #:restricted-to filter-fn))

(define TAG_REGEXP #px"((?<=^)|(?<=[[:blank:]]))#[A-Za-z0-9]+")

(define (extract-tags feat)
  (regexp-match* TAG_REGEXP (rec-prop feat 'explanation)))

(define (has-tag? feat tag)
  (member (string-append "#" tag)
          (extract-tags feat)))

;; XXX replace with every at some point
(define (has-all-tags? feat tags)
  (cond
    ((null? tags) #t)
    ((has-tag? feat (car tags)) (has-all-tags? feat (cdr tags)))
    (else #f)))

(define (gen-tag-list post-pool)
  (sort (apply lset-union string=? (map extract-tags post-pool))
        string<?))

(define (post-pre-pop-tag-str tags)
  (if (empty? tags)
      ""
      (string-append " " (string-join (map (cut string-append "#" <>) tags) " "))))
