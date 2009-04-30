#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         mzlib/defmacro
         "app.scm"
         "data.ss"
         "social.ss"
         "discuss.ss"
         "templates.ss"
         "admin.ss")

(provide index-page-view
         feature-detail-page-view
         gen-show-list-view
         )

(define (req-link sesh str)
  `(a ((href ,(body-as-url (req)
                           (post-feature-view sesh))))
      ,str))

(define (div-footer)
  `(div ((id "ft")) ,standard-footer))

(define (index-page-view sesh #:form-view (form-markup request-feature-form-view))
  (page
   #:design (base-design)
   `(div ((id "docindex"))
         (div ((id "indexhd"))
              (h1 "lawnelephant"))
         (div ((id "bd"))
              (div ((id "elephant-holder"))
                   (img ((src "i/elephant.jpg")))))
         (div ((id "indexft")) 
              (ul
                ,(li-a "/popular" "all"))
               (ul 
                   ,(li-a "http://blog.lawnelephant.com/post/74637624/introducing-lawnelephant-com" "about")
                   ,(li-a "http://blog.lawnelephant.com" "blog")
                   ,(li-a "http://github.com/vegashacker/lawnelephant/tree/master" "source code")
                   ,(li-a "mailto:ask@lawnelephant.com" "ask@lawnelephant.com")
                   ,(li-a "http://twitter.com/lawnelephant" "@lawnelephant"))
                   ;; XXX goog analytics really needs to be just before the closing body tag, but I
                   ;; don't know how to put it there just yet
                  ,(raw-str goog-analytics)))))
              


(define (post-feature-view sesh #:form-view (form-markup request-feature-form-view))
  (page
   #:design (base-design)
   `(div ((id "doc"))
         (div ((id "hd"))
              (a ((href "/"))
                      (span ((id "text-logo")) "lawnelephant")))
         (div ((id "bd"))
              (div ((id "requests"))
                   ,(form-markup sesh)))
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


(define (list-page-view sesh title feat-pool)
  (page
   #:design (base-design #:title (format "~A | lawnelephant" title))
   `(div ((id "doc"))
         (div ((id "hd"))
                   (a ((href "/"))
                      (span ((id "text-logo")) "lawnelephant"))
                   (div ((id "posta"))
                        ,(req-link sesh "post")))
              
         (div ((id "bd"))
              (ul ,@(map (cut feature-req-view sesh <>)
                         (feat-pool))))
         ,(div-footer))))

(define (gen-show-list-view type-str sesh)
  (list-page-view sesh type-str
                  (cond ((string=? type-str "popular") get-feature-requests-popular)
                        ((string=? type-str "newest") get-feature-requests-newest)
                        ((string=? type-str "completed") get-feature-requests-completed)
                        (else (e "Unrecognized list type str ~A" type-str)))))

(define (request-feature-form-view sesh)
  (form '((explanation "" long-text))
        #:submit-label "post"
        #:init `((type . feature-request)
                 (author. ,(session-id sesh)))
        #:error-wrapper (lambda (error-form-view)
                          (index-page-view sesh #:form-view
                                           (lambda (sesh) error-form-view)))
        #:validate feature-request-validator
        #:on-done (lambda (feat)
                    (redirect-to (page-url feature-detail-page (rec-id feat))))))

(define (feature-detail-page-view sesh feat)
  (let ((exp-raw (string-trim (rec-prop feat 'explanation)))
        (exp (feature-request-expl feat)))
    (page
     #:design (base-design #:title (format "~A | lawnelephant" (string-ellide exp-raw 15)))
     `(div ((id "doc"))
           (div ((id "hd"))
                (span ((id "header")) 
                      ,(web-link "lawnelephant.com" (setting *WEB_APP_URL*))
                      " > feature details"))
           ,(let ((detail-url (page-url feature-detail-page (rec-id feat))))
             `(div ((id "bd")) 
                   (p ,exp)
                   (p ((class "reply"))
                         ,(comment-on-item-link feat sesh #:redirect-to detail-url))
                   ,(show-all-comments-view sesh feat #:threaded #t #:redirect-to detail-url)))
           ,(div-footer)))))


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

(define (feature-req-view sesh feat)
  `(li (span ((class "explanation"))
             ,(if (equal? "missing" (feature-request-expl-no-markup feat))
                (rec-prop feat 'body)
                (feature-request-expl-no-markup feat)))
       (span ((class "ago"))
             ,(time-ago (rec-prop feat 'created-at)))
       (span ((class "reply"))
             ,(comment-on-item-link feat sesh #:redirect-to (page-url feature-detail-page (rec-id feat))))
       ,(if (> (count-comments feat) 0)
          `(ul ((class "indent")) ,@(map (λ(x) (feature-req-view sesh x))
                      (get-comments feat)))
          "")))



(define (feature-req-viewa sesh feat)
  (let ((is-completed? (rec-prop feat 'completed)))
    `(li (span ((class "explanation"))
               ,(web-link (string-ellide (feature-request-expl-no-markup feat) 120)
                          (page-url feature-detail-page (rec-id feat))))
         (div ((class "explanation-rest"))
              (span ((class "points")) 
                   ,(format "~A" (vote-score feat)))

              " points posted "
              ,(time-ago (rec-prop feat 'created-at))
              " "
              ,(xexpr-if is-completed?
                         "completed ")

              ,(let ((it (count-comments feat)))
                   (cond
                     ((> it 1) (format "[~A comments] " it))
                     ((< it 1) "")
                     (else (format "[~A comment] " it))))

              ,(xexpr-if (and (not is-completed?) (can-vote-on? sesh feat))
                         ;;XXX looks like a named let could work here
                         (let ((votelink (lambda (dir)
                                                 `(a ((href ,(make-voter-url sesh feat dir))
                                                      (class ,dir))
                                                      ,(format "[vote ~A]" dir)))))
                           (** " " (votelink "up") " " (votelink "down"))))

              ,(xexpr-if (in-admin-mode?)
                         (delete-entry-view feat))
              ,(xexpr-if (and (not is-completed?) (in-admin-mode?))
                         (mark-as-completed-view feat))))))

(define (delete-entry-view feat-req-rec)
  (** " "
      (web-link "[delete]" (body-as-url (req) (delete-rec! feat-req-rec) 
                                        (redirect-to (page-url index-page))))))

(define (mark-as-completed-view feat-req-rec)
  (** " "
      (web-link "[mark completed]" (body-as-url (req)
                                                (rec-set-prop! feat-req-rec 'completed #t)
                                                (store-rec! feat-req-rec)
                                                (redirect-to (page-url index-page))))))


