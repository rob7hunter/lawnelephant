#lang scheme/base

;; this is a generic dicussion engine.  we won't make it so generic to start, but
;; at least we'll try not to lock it down to be just about, say, feature request records.

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 0)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 5 (= 0)))
         "templates.ss" ;XXX shouldn't be here - need to abstract out at some point
         "data.ss"
         )

(provide comment-on-item-link
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
                  (span ((id "text-logo")) "lawnelephant"))
               (span ((id "arrow"))
                     ,(raw-str "&rarr;"))
               (span ((id "singlethread")) "reply to comment"))
          (div ((id "bd"))
               (div ((id "text-you-are-replying-to"))
                    "You are replying to:"
                    (br)
                    (span ((class "explanation"))
                          ,(if (equal? "missing" (feature-request-expl-no-markup parent-item))
                             (rec-prop parent-item 'body)
                             (feature-request-expl parent-item))))
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

(define (count-comments feat-or-reply)
  (let ((comments (get-comments feat-or-reply)))
    (apply + (length comments) (map count-comments comments))))

(define (get-comments parent-item)
  (load-children parent-item 'comments))
