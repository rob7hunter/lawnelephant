#lang scheme/base

;; this is a generic dicussion engine.  we won't make it so generic to start, but
;; at least we'll try not to lock it down to be just about, say, feature request records.

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         "templates.ss" ;;XXX shouldn't be here - need to abstract out at some point
         "data.ss"
         )

(provide comment-on-item-link
         show-all-comments-view
         show-comment-view
         get-comments
         count-comments
         )

(define (comment-on-item-link item sesh
                              #:link-prose (prose "reply")
                              #:redirect-to (redirect #f))
  (web-link prose (body-as-url (req)
                               (create-comment-view item sesh #:redirect-to redirect))))


(define (create-comment-view parent-item sesh #:redirect-to (redirect #f))
  (page
   #:design (base-design)
   `(div ((id "doc"))
         (div ((id "hd"))
              (a ((href "/"))
                      (span ((id "text-logo")) "lawnelephant")))
         (div ((id "bd"))
              (div ((id "requests"))

                  ,(form '((body "" long-text))
                            #:submit-label "reply"
                            #:init `((type . comment)
                                     (author . ,(session-id sesh)))
                            #:on-done (lambda (comment-rec)
                                        (add-child-and-save! parent-item 'comments comment-rec)
                                        (if redirect
                                            (redirect-to redirect)
                                            "comment saved.")))))
         (div ((id "indexft")) 
               (ul 
                   ,(li-a "http://blog.lawnelephant.com/post/74637624/introducing-lawnelephant-com" "about")
                   ,(li-a "http://blog.lawnelephant.com" "blog")
                   ,(li-a "http://github.com/vegashacker/lawnelephant/tree/master" "source code")
                   ,(li-a "mailto:ask@lawnelephant.com" "ask@lawnelephant.com")
                   ,(li-a "http://twitter.com/lawnelephant" "@lawnelephant"))
                   ;; XXX goog analytics really needs to be just before the closing body tag, but I
                   ;; don't know how to put it there just yet
                  ,(raw-str goog-analytics)))))

(define (show-all-comments-view sesh parent-item
                                #:threaded (threaded #f)
                                #:redirect-to (redirect #f))
  `(ul ((class "thread")) ,@(map (lambda (com) `(li ,(show-comment-view sesh com
                                                     #:threaded threaded
                                                     #:reply-link #t
                                                     #:redirect-to redirect)))
              (get-comments parent-item))))

(define (show-comment-view sesh
                           comment
                           #:threaded (threaded #f)
                           #:reply-link (reply-link #f)
                           #:redirect-to (redirect #f))
  (define (show-indiv-comment c sesh)
    `(div ((class "comment"))
          ,(any-body-markup (rec-prop c 'body))
          ,@(splice-if reply-link `(div ((class "reply-link"))
                                        ,(comment-on-item-link c
                                                               sesh
                                                               #:link-prose "reply"
                                                               #:redirect-to redirect)))))
  (if (not threaded)
      (show-indiv-comment comment sesh)
      ;; o/w we need to do some snazzy recursion...
      (let lp ((cur comment))
        `(div ((class "thread"))
              ,(show-indiv-comment cur sesh)
              (ul ,@(map (lambda (reply) `(li ,(lp reply)))
                         (get-comments cur)))))))

(define (count-comments feat-or-reply)
  (let ((comments (get-comments feat-or-reply)))
    (apply + (length comments) (map count-comments comments))))

(define (get-comments parent-item)
  (load-children parent-item 'comments))
