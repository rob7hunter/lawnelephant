#lang scheme/base

;; this is a generic dicussion engine.  we won't make it so generic to start, but
;; at least we'll try not to lock it down to be just about, say, feature request records.

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         "templates.ss" ;;XXX shouldn't be here - need to abstract out at some point
         )

(provide comment-on-item-link
         show-all-comments-view
         show-comment-view
         get-comments
         count-comments
         )

(define (comment-on-item-link item
                              #:link-prose (prose "comment")
                              #:redirect-to (redirect #f))
  (web-link prose (body-as-url (req)
                               (create-comment-view item #:redirect-to redirect))))

(define (create-comment-viewa parent-item #:redirect-to (redirect #f))
  (form '((body "" long-text))
        #:submit-label "Comment"
        #:init '((type . comment))
        #:on-done (lambda (comment-rec)
                    (add-child-and-save! parent-item 'comments comment-rec)
                    (if redirect
                        (redirect-to redirect)
                        "comment saved."))))
;;XXX this doesn't belong in discuss.ss - form does, and needs
;;an abstracted wrapper. 

(define (create-comment-view parent-item #:redirect-to (redirect #f))
  (page
   #:design (base-design)
   `(div ((id "doc"))
         (div ((id "hd"))
              (a ((href "/")) 
                 (h1 "lawnelephant")))
         (div ((id "bd"))
              ,(form '((body "" long-text))
                        #:submit-label "Comment"
                        #:init '((type . comment))
                        #:on-done (lambda (comment-rec)
                                    (add-child-and-save! parent-item 'comments comment-rec)
                                    (if redirect
                                        (redirect-to redirect)
                                        "comment saved."))))
         (div ((id "ft")) 
              (ul ((class "simple"))
                   ,(li-a "http://github.com/vegashacker/lawnelephant/tree/master" "source code")
                   ,(li-a "http://blog.lawnelephant.com" "blog")
                   ,(li-a "mailto:ask@lawnelephant.com" "ask@lawnelephant.com"))))))
;;XXX using nonstandard footer - don't want goog analytics to track this page

(define (show-all-comments-view parent-item
                                #:threaded (threaded #f)
                                #:redirect-to (redirect #f))
  `(ul ((class "thread")) ,@(map (lambda (com) `(li ,(show-comment-view com
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
          ,@(splice-if reply-link `(div ((class "reply-link"))
                                        ,(comment-on-item-link c
                                                               #:link-prose "reply"
                                                               #:redirect-to redirect)))))
  (if (not threaded)
      (show-indiv-comment comment)
      ;; o/w we need to do some snazzy recursion...
      (let lp ((cur comment))
        `(div ((class "thread"))
              ,(show-indiv-comment cur)
              (ul ,@(map (lambda (reply) `(li ,(lp reply)))
                         (get-comments cur)))))))

;;XXX suspect but can't prove that this could be shorter
(define (count-comments feat)
  (let ((feats (get-comments feat)))
    (aif (length feats)
         (apply + it (map count-comments feats))
         0)))

(define (get-comments parent-item)
  (load-children parent-item 'comments))
