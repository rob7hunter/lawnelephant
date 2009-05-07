#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         "app.scm"
         "view.ss"
         "data.ss"
         "admin.ss")

(define-session-page (index-page req sesh)
  #:blank #t
  (index-page-view sesh))



(define-session-page (popular-page req sesh)
  #:blank #t
  (gen-show-list-view "popular" sesh))

(define-session-page (newest-page req sesh)
  #:blank #t
  (gen-show-list-view "newest" sesh))

(define-session-page (completed-page req sesh)
  #:blank #t
  (gen-show-list-view "completed" sesh))


(define-session-page (signin-page req sesh)
  (welcome-message sesh #:no-register #t))

(define-admin-session-page (adminified-index-page req sesh page-type-str)
  #:blank #t
  (admin-mode (gen-show-list-view page-type-str sesh)))

;; caches

(define-type-cache feature-request)
