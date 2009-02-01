#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1))))

(define-app my-app
  (index-page (url "/"))
  (feature-feed-page (url "/atom"))
  (signin-page (url "/signin"))
  (adminified-index-page (url "/admin"))
  )

  
