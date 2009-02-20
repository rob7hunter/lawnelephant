#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         "social.ss"
         )

(provide get-feature-requests-popular
         get-feature-requests-newest
         get-feature-requests-completed
         feature-request-expl
         feature-request-validator)

(define (get-feature-requests-completed)
  (get-feature-requests-generic #:restricted-to completed?
                                #:sort-by vote-score))

(define (get-feature-requests-popular)
  (get-feature-requests-generic #:restricted-to (lambda (x) (not (completed? x)))
                                #:sort-by vote-score))

(define (get-feature-requests-newest)
  (get-feature-requests-generic #:restricted-to (lambda (x) (not (completed? x)))))

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
  (or (aand (rec-prop fr-rec 'explanation) (string-trim it))
      "missing"))

(define (feature-request-validator fr-rec)
  (let ((lookup (rec-prop fr-rec 'explanation)))
    (and (or (not lookup) (string=? "" (string-trim lookup)))
         "Please fill in a feature request in the text box.")))
