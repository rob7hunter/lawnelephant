#lang scheme/base

;; Note: the expectation is that this will be moved into the core of LeftParen.

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 5 (= 1))))

(provide define*)

(declare-setting *ALLOW_DEFINE_DEBUG* #f)

;; contains raw-implementations of functions (not indirected)
(define *debug-name->fn* (make-hash))

(define-syntax define*
  (syntax-rules ()
    ((_ (name args ...) body ...)
     ;; mmm could beef this up so that it displays "redefining..." when you are
     (begin (hash-set! *debug-name->fn* 'name (lambda (args ...) body ...))
            (define name
              (make-keyword-procedure
               (lambda (kws kw-vals . reg-args)
                 (if (setting *ALLOW_DEFINE_DEBUG*)
                     (keyword-apply (hash-ref *debug-name->fn* 'name)
                                    kws kw-vals reg-args)
                     (e "Dynamic debugging is not allowed on this server.")))))
            'done))))
