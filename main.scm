#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         "app.scm"
         "view.ss"
         "admin.ss")

(define-session-page (index-page req sesh)
  #:blank #t
  (index-page-view))

(define-session-page (signin-page req sesh)
  (welcome-message sesh))

(define-admin-session-page (adminified-index-page req sesh)
  #:blank #t
  (admin-mode (index-page-view)))
