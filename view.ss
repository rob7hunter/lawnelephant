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

(define (index-page-view sesh #:form-view (form-markup request-feature-form-view))
  (page
   #:design (base-design)
   `(div ((id "doc"))
         
         (div ((id "hd"))
              (a ((href "/")) 
                 (h1 "lawnelephant")))
         (div ((id "bd"))
              (div ((id "elephant-holder"))
                   (img ((src "i/elephant.jpg"))))
              (div ((id "commentary"))
                   ,(web-link "request a feature"
                             (body-as-url (req)
                                          (post-feature-view sesh))))
         (div ((id "ft")) ,standard-footer)))))


(define (post-feature-view sesh #:form-view (form-markup request-feature-form-view))
  (page
   #:design (base-design)
   `(div ((id "doc"))
         
         (div ((id "hd"))
              (a ((href "/")) 
                 (h1 "lawnelephant")))
         (div ((id "bd"))
              (div ((id "requests"))
                   ,(form-markup sesh)))
         (div ((id "ft")) ,standard-footer))))

(define (list-page-view sesh title feat-pool #:form-view (form-markup request-feature-form-view))
  (page
   #:design (base-design #:title (format "~A | lawnelephant" title))
   `(div ((id "doc"))
         (div ((id "hd"))
              (a ((href "/")) 
                 (h1 "lawnelephant")))
         (div ((id "bd"))
              (div ((id "commentary"))
                   ,(web-link "request a feature"
                             (body-as-url (req)
                                          (post-feature-view sesh))))
              ,(let ((tab-content
                      (lambda (feat-fn)
                        `(div (ul ,@(map (cut feature-req-view sesh <>)
                                                  (feat-fn)))))))
                 (tab-content feat-pool)))
         (div ((id "ft")) ,standard-footer))))

(define (gen-show-list-view type-str sesh)
  (list-page-view sesh type-str
                  (cond ((string=? type-str "popular") get-feature-requests-popular)
                        ((string=? type-str "newest") get-feature-requests-newest)
                        ((string=? type-str "completed") get-feature-requests-completed)
                        (else (e "Unrecognized list type str ~A" type-str)))))

(define (request-feature-form-view sesh)
  (form '((explanation "" long-text))
        #:submit-label "Request a Feature"
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
           (div ((id "ft")) ,standard-footer)))))


(define (make-ago-string str num)
  (format "~A ~A ago" 
          num 
          (if (eqv? 1 num) 
            (format "~A" str)
            (format "~As" str))))

(define (time-ago created)
  (let ((ago (- (current-seconds) created)))
    (cond
      ((> ago (* 60 60 24)) 
       (let ((number (round (/ ago (* 60 60 24)))))
         (make-ago-string "day" number)))
      ((> ago (* 60 60)) 
       (let ((number (round (/ ago (* 60 60)))))
         (make-ago-string "hour" number)))
      ((> ago (* 60)) 
       (let ((number (round (/ ago (* 60)))))
         (make-ago-string "minute" number)))
      (else 
        (let ((number (round (/ ago 1))))
         (make-ago-string "second" number))))))

(define (feature-req-view sesh feat)
  (let ((is-completed? (rec-prop feat 'completed)))
    `(li (span ((class "explanation"))
               ,(web-link (string-ellide (feature-request-expl-no-markup feat) 60)
                          (page-url feature-detail-page (rec-id feat))))
         (div ((class "explanation-rest"))
              ,(time-ago (rec-prop feat 'created-at))
              " "
              ,(xexpr-if is-completed?
                         "completed ")
              ,(web-link 
                 (let ((it (count-comments feat)))
                   (cond
                     ((> it 1) (format "[~A comments]" it))
                     ((< it 1) "[discuss]")
                     (else (format "[~A comment]" it))))
                 (page-url feature-detail-page (rec-id feat)))
              " "

              (span ((class "pts")) 
                   ,(format "~A" (vote-score feat)))

              " pts"

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


