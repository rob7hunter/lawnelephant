#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 1)))
         "modes.ss")

(provide admin-mode
         in-admin-mode?
         define-admin-session-page
         )

(define-mode admin-mode in-admin-mode?)

(define-syntax define-admin-session-page
  (syntax-rules ()
    ((_ (page-name req sesh args ...) body ...)
     (define-session-page (page-name req sesh args ...)
       #:blank #t
       (if-these-users '(vegashacker gersteni) sesh
                       (page body ...)
                       "Admin elephants only.")))))
