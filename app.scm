#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 1))))

(define-app my-app
  (index-page (url "/"))
  (feature-detail-page (url "/feature/" (string-arg)))
  (signin-page (url "/signin"))
  (adminified-index-page (url "/admin/" (string-arg)))
  (tag-page-no-tags (url "/tag"))
  (tag-page (url "/tag/" (string-arg)))
  )

  
