#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         "app.scm"
         "view.ss"
         "admin.ss")

(define-session-page (index-page req sesh)
  #:blank #t
  (index-page-view sesh))

(define-page (feature-detail-page req feat-id)
  #:blank #t
  (only-rec-of-type feat-id feature-request (f)
                    (feature-detail-page-view f)))

(define-session-page (signin-page req sesh)
  (welcome-message sesh #:no-register #t))

(define-admin-session-page (adminified-index-page req sesh)
  #:blank #t
  (admin-mode (index-page-view sesh)))

