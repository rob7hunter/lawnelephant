#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1))))

(define-app my-app
  (index-page (url "/"))
  (popular-page (url "/popular"))
  (newest-page (url "/newest"))
  (completed-page (url "/completed"))
  (feature-detail-page (url "/feature/" (string-arg)))
  (signin-page (url "/signin"))
  (adminified-index-page (url "/admin/" (string-arg)))
  )

  
