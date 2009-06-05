#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 1)))
         "app.scm"
         "view.ss"
         "data.ss"
         "admin.ss")

(define-session-page (index-page req sesh)
  #:blank #t
  (gen-tag-page sesh #f))


;; This supports slugified urls.
;; We take the parameter, and throw away everything after the 
;; letters and the numbers at the start. So now we are free to
;; construct slugified urls elsewhere in the product.

(define-session-page (feature-detail-page req sesh feat-id-and-slug)
  #:blank #t
  (let ((feat-id (car (regexp-match #px"[a-z0-9]*" feat-id-and-slug))))
       (only-rec-of-type feat-id post (f)
                         (feature-detail-page-view sesh f))))


(define-session-page (signin-page req sesh)
  (welcome-message sesh #:no-register #t))

;; XXX need to get back to this one
;(define-admin-session-page (adminified-index-page req sesh page-type-str)
;  #:blank #t
;  (admin-mode (gen-show-list-view page-type-str sesh)))

(define-page (article-feed-page req tag)
             #:blank #t
                     (gen-rss-page tag))

(define-session-page (tag-page req sesh tag)
  #:blank #t
  (gen-tag-page sesh tag))

(define-session-page (tag-page-no-tags req sesh)
  #:blank #t
  (gen-tag-page sesh #f))

;; caches

(define-type-cache post)
