#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 5 (= 1)))
         mzlib/defmacro
         "app.scm"
         "data.ss"
         "social.ss"
         "discuss.ss"
         "templates.ss"
         "markup.ss"
         "tags.ss"
         "admin.ss")

(provide 
         feature-detail-page-view 
         gen-tag-page
         gen-rss-page
         )

(define (slugify xs)
  (cond
    ((null? xs) "")
    (else
      (string-append (car xs) "-" (slugify (cdr xs))))))

(define (gen-feature-link feat)
  (format "/feature/~A~A~A"
          (rec-id feat)
          "-"
          (car (regexp-match 
                 #px".{,20}[[:alnum:]]" 
                 (slugify 
                   (regexp-split #px"[^[:alnum:]]+" 
                                 (rec-prop feat 'body)))))))

(define (post-feature-view sesh 
                           #:post-pool (post-pool #f) 
                           #:tag-list (tags #f) 
                           #:form-view (form-markup (cut request-feature-form-view
                                                         sesh
                                                         (or tags '()))))
  (page
    #:design (base-design)
    `(div ((id "doc"))
          ,(xexpr-if (and post-pool tags) (awesomecloud post-pool tags))
          (div ((id "bd"))
               (div ((id "requests"))
                    ,(form-markup)))
          (div ((id "instructions"))
               "Make your post easier to find by adding tags. Just put a # before any word to turn it into a tag. For example "
               ,(web-link "#feature" "/tag/feature")
               " or "
               ,(web-link "#question" "/tag/question"))
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

(define (feature-detail-page-view sesh feat-id)
  (page
    #:design (base-design #:title "permalink at lawnelephant")
    `(div ((id "doc"))
          (div ((id "hd"))
               (a ((href "/"))
                  (span ((id "text-logo")) "lawnelephant"))
               (span ((id "arrow"))
                     ,(raw-str "&rarr;"))
               (span ((id "singlethread")) "you are looking at a single thread"))
          (div ((id "bd"))
               (ul ,(feature-req-view sesh feat-id #:reply-redirect (gen-feature-link feat-id))))
          ,(div-footer))))

(define (gen-rss-page tag) "")


(define (gen-tag-page sesh tag)
  (let* ((tags (if tag 
                 (regexp-split #px"[^[:alnum:]]" tag)
                 '()))
         (post-pool (if tag 
                      (get-feature-requests-by-tags tags)
                      (get-feature-requests-generic))))
    (page
      #:design (base-design #:title (aif tag ; to handle when tag is #f
                                         (format "~A at lawnelephant" it)
                                         "all posts at lawnelephant"))
      `(div ((id "doc"))
            (div ((class "tbd")) (h1 "lawnelehant: twitter + threads + tags"))
            ,(awesomecloud post-pool tags)
            ,(subhead-div sesh #:post-pool post-pool #:tag-list tags)
            (div ((id "bd"))
                 (ul ,@(map (cut feature-req-view sesh #:tags tags <>) post-pool)))
            ,(div-footer)

            (div ((id "adage"))
                 ,(let* ((adages (get-feature-requests-generic #:restricted-to (cut has-tag? <> "adage")))
                         (adage (list-ref adages (random (length adages)))))
                    `(span ,(markup-body (rec-prop adage 'body)))))))))

;; note: use delete-duplicates to handle posts like: "#idoh #idoh something ..."

(define (awesomecloud post-pool tag-list #:title (title #f)) 
  `(div ((id "awesomecloud")) 
        ,(xexpr-if title
                   `(span (a ((href "/") 
                              (id "text-logo")) ,title)
                          (span ((id "arrow")))
                          ,(raw-str "&rarr;")))
        ,@(map (lambda (t) (tag-subst t #:supress-hash #t #:tag-list tag-list))
               (delete-duplicates (gen-tag-list post-pool)))))

(define (subhead-div sesh 
                     #:post-pool (post-pool #f) 
                     #:tag-list (tags #f))
  `(div ((id "posta"))
        ,(form '((body "" text))
               #:submit-label "post"
               #:init `((type . post)
                        (author. ,(session-id sesh))
                        (body . ,(post-pre-pop-tag-str tags)))
               #:skip-br #t
               #:validate feature-request-validator
               #:on-done (lambda (x) (redirect-to "/tag")))))

(define (request-feature-form-view sesh tags)
  (form '((body "" long-text))
        #:submit-label "post"
        #:init `((type . post)
                 (author. ,(session-id sesh))
                 (body . ,(post-pre-pop-tag-str tags)))
        #:validate feature-request-validator
        #:on-done (lambda (x) (redirect-to "/tag"))))

(define (make-ago-string str num)
  (format "~A ~A ago" 
          num 
          (if (eqv? 1 num) 
            (format "~A" str)
            (format "~As" str))))

(define (time-ago created)
  (let ((ago (- (current-seconds) created)))
    (cond
      ((> ago 86400) 
       (make-ago-string "day" (round (/ ago 86400))))
      ((> ago 3600) 
       (make-ago-string "hour" (round (/ ago 3600))))
      ((> ago 60) 
       (make-ago-string "minute" (round (/ ago 60))))
      (else 
        (make-ago-string "second" ago)))))

(define (feature-req-view sesh feat #:reply-redirect (reply-redirect #f) #:tags (tags #f))
  `(li ((id ,(format "~A" (rec-id feat))))
       (span ((class "explanation")) ,(post-body feat))
       (span ((class "ago")) ,(format " ~A with " (time-ago (rec-prop feat 'created-at))))
       (span ((class "pts")) ,(format "~A" (vote-score feat)))
       (span ((class "ago")) ,(format " vote~A" (if (eq? 1 (vote-score feat)) "" "s")))
       ,(comment-on-item-link feat sesh #:redirect-to (aif reply-redirect it "/tag")) 
       ,(xexpr-if (rec-type-is? feat 'post)
                  `(span ((class "features-only"))
                         ,(xexpr-if (in-admin-mode?)
                                    (delete-entry-view feat))

                         ,(xexpr-if (and (not (completed? feat))
                                         (in-admin-mode?))
                                    (mark-as-completed-view feat))))

       ,(xexpr-if (can-vote-on? sesh feat)
                  `(a ((href ,(make-voter-url sesh feat "up"))
                       (class "up"))
                      ,(raw-str "&#9734;")))
       ;XXX doesn't look proper, shouldn't I be able to just (when (get-comments feat) ...)
       (div ((class "inline-reply"))
            ,(form '((body "" text))
                   #:submit-label "reply"
                   #:skip-br #t
                   #:init `((type . comment)
                            (author . ,(session-id sesh)))
                   #:on-done (lambda (comment-rec)
                               (add-child-and-save! feat 'comments comment-rec)
                               (redirect-to (format "/tag/~A#~A" 
                                                    (if tags (tags-to-url tags) "") 
                                                    (rec-id comment-rec))))))
       ,(xexpr-if (> (count-comments feat) 0)
                  `(ul ((class "indent")) 
                       ,@(map (λ(x) (feature-req-view sesh 
                                                       x 
                                                       #:tags tags
                                                       #:reply-redirect reply-redirect))
                                                 (get-comments feat))))))

(define (delete-entry-view feat-req-rec)
  (** " "
      (web-link "[delete]" (body-as-url (req) (delete-rec! feat-req-rec) 
                                        (redirect-to (page-url index-page))))))

(define (mark-as-completed-view feat-req-rec)
  (** " "
      (web-link "[mark completed]" 
                (body-as-url (req)
                             (unless (completed? feat-req-rec)
                               (rec-set-prop! feat-req-rec
                                              'body
                                              (string-append (post-body feat-req-rec)
                                                             " #complete"))
                               (store-rec! feat-req-rec))
                             (redirect-to (page-url index-page))))))


