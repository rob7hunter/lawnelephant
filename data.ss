#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 5 (= 1)))
         "social.ss"
         "markup.ss"
         "tags.ss"
         )

(provide get-feature-requests-popular
         get-feature-requests-newest
         get-feature-requests-completed
         get-feature-requests-by-tags
         get-feature-requests-generic 
         feature-request-expl
         any-body-markup
         feature-request-expl-no-markup
         feature-request-validator)

(define (get-feature-requests-completed)
  (get-feature-requests-generic #:restricted-to completed?
                                #:sort-by reddit-score))

(define (get-feature-requests-popular)
  (get-feature-requests-generic #:restricted-to (lambda (x) (not (completed? x)))
                                #:sort-by reddit-score))

(define (get-feature-requests-newest)
  (get-feature-requests-generic #:restricted-to (lambda (x) (not (completed? x)))))

(define (get-feature-requests-by-tags tag)
  (get-feature-requests-generic #:restricted-to (lambda (feat) 
                                                  (has-all-tags? feat tag))))

(define (get-feature-requests-generic #:restricted-to (filter-fn #f)
                                      #:sort-by (sort-by 'created-at))
  (load-where #:type 'feature-request
              #:sort-by sort-by
              #:compare >
              #:restricted-to filter-fn))

(define completed? (cut rec-prop <> 'completed))

;; note that we don't implement this as
;; (rec-prop fr-rec 'explanation "missing") because we want to catch, in
;; belt-and-suspenders fashion, the case where there actually is a #f value set in the
;; record.  But, in reality, if you do see "missing" on the site, it means that
;; something got screwed up, or we aren't validating correctly or something.
(define (feature-request-expl fr-rec)
  (or (aand (rec-prop fr-rec 'explanation) (any-body-markup it))
      "missing"))

(define (feature-request-expl-no-markup fr-rec)
  (or (rec-prop fr-rec 'explanation)
      "missing"))

(define (any-body-markup str)
  (markup-body (string-trim str)))

(define (feature-request-validator fr-rec)
  (let ((lookup (rec-prop fr-rec 'explanation)))
    (and (or (not lookup) (string=? "" (string-trim lookup)))
         "Please fill in a feature request in the text box.")))
