#lang scheme/base

;; this is a generic dicussion engine.  we won't make it so generic to start, but
;; at least we'll try not to lock it down to be just about, say, feature request records.

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         )

(provide comment-on-item-link
         show-all-comments-view
         show-comment-view
         )

(define (comment-on-item-link item
                              #:link-prose (prose "comment")
                              #:redirect-to (redirect #f))
  (web-link prose (body-as-url (req)
                               (create-comment-view item #:redirect-to redirect))))

(define (create-comment-view parent-item #:redirect-to (redirect #f))
  (form '((body "" long-text))
        #:submit-label "Comment"
        #:init '((type . comment))
        #:on-done (lambda (comment-rec)
                    (add-child-and-save! parent-item 'comments comment-rec)
                    (if redirect
                        (redirect-to redirect)
                        "comment saved."))))

(define (show-all-comments-view parent-item
                                #:threaded (threaded #f)
                                #:redirect-to (redirect #f))
  `(ul ,@(map (lambda (com) `(li ,(show-comment-view com
                                                     #:threaded threaded
                                                     #:reply-link #t
                                                     #:redirect-to redirect)))
              (get-comments parent-item))))

(define (show-comment-view comment
                           #:threaded (threaded #f)
                           #:reply-link (reply-link #f)
                           #:redirect-to (redirect #f))
  (define (show-indiv-comment c)
    `(div ((class "comment"))
          ,(rec-prop c 'body)
          ,@(splice-if reply-link (comment-on-item-link c
                                                        #:link-prose "reply"
                                                        #:redirect-to redirect))))
  (if (not threaded)
      (show-indiv-comment comment)
      ;; o/w we need to do some snazzy recursion...
      (let lp ((cur comment))
        `(div ((class "thread"))
              ,(show-indiv-comment cur)
              (ul ,@(map (lambda (reply) `(li ,(lp reply)))
                         (get-comments cur)))))))

(define (get-comments parent-item)
  (load-children parent-item 'comments))
