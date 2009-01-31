#lang scheme/base

;; Note: this is eventually going to go into LeftParen itself.

(provide define-mode)

(define-syntax define-mode
  (syntax-rules ()
    ((_ mode-invoker-name mode-predicate-name)
     (begin (define param (make-parameter #f))
            (define-syntax mode-invoker-name
              (syntax-rules ()
                ((_ body (... ...))
                 (parameterize ((param #t))
                   body (... ...)))))
            (define (mode-predicate-name)
              (param))))))
