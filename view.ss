#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         mzlib/defmacro
         "app.scm"
         "data.ss"
         "social.ss"
         "discuss.ss"
         "admin.ss")


(provide index-page-view
         feature-detail-page-view
         base-design
         list-page-view
         )


(define goog-analytics 
  "
  <script type=\"text/javascript\">
  var gaJsHost = ((\"https:\" == document.location.protocol) ? \"https://ssl.\" : \"http://www.\");
  document.write(unescape(\"%3Cscript src='\" + gaJsHost + \"google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E\"));
  </script>
  <script type=\"text/javascript\">
  try {
  var pageTracker = _gat._getTracker(\"UA-7294827-1\");
  pageTracker._trackPageview();
  } catch(err) {}</script>
")

(define (li-a link name) 
  `(li (a ((href ,link)) ,name)))

(define standard-footer
  `(div 
     (ul ((class "simple"))
         (li "features:")
         ,(li-a "/popular" "popular")
         ,(li-a "/newest" "newest")
         ,(li-a "/completed" "completed"))
     (ul ((class "simple"))
       ,(li-a "http://blog.lawnelephant.com/post/74637624/introducing-lawnelephant-com" "about")
       ,(li-a "http://blog.lawnelephant.com" "blog")
       ,(li-a "http://github.com/vegashacker/lawnelephant/tree/master" "source code")
       ,(li-a "mailto:ask@lawnelephant.com" "ask@lawnelephant.com")
       ;; XXX goog analytics really needs to be just before the closing body tag, but I
       ;; don't know how to put it there just yet
      ,(raw-str goog-analytics))))

(define (index-page-view sesh #:form-view (form-markup request-feature-form-view))
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
              (div ((id "requests"))
                   ,(form-markup sesh))
              ,(let ((tab-content
                      (lambda (feat-fn)
                        `(div (ul ,@(map (cut feature-req-view sesh <>)
                                                  (feat-fn)))))))
                 (tab-content feat-pool)))
         (div ((id "ft")) ,standard-footer))))


(define (request-feature-form-view sesh)
  (form '((explanation "" long-text))
        #:submit-label "Request a Feature"
        #:init `((type . feature-request)
                 (author. ,(session-id sesh)))
        #:error-wrapper (lambda (error-form-view)
                          (index-page-view sesh #:form-view
                                           (lambda (sesh) error-form-view)))
        #:validate feature-request-validator))

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
              ,(xexpr-if (and (not is-completed?) (can-vote-on? sesh feat))
                         (** `(span ((class "votelink"))
                                   ,(web-link "[vote up]" (make-voter-url sesh feat "up")))
                             " "
                             `(span ((clas "votelink"))
                                    ,(web-link "[vote down]" (make-voter-url sesh feat "down")))
                             " "))

              (span ((class "pts")) 
                   ,(format "~A pts " (vote-score feat)))

              ;;the spans above will be used for hacker-news style voting

              ,(xexpr-if (in-admin-mode?)
                         (delete-entry-view feat))
              ,(xexpr-if (and (not is-completed?) (in-admin-mode?))
                         (mark-as-completed-view feat))))))

(define-page (feature-feed-page req)
  #:blank #t
  (atom-feed feature-feed-page 
             #:feed-title "features for lawnelephant"
             #:feed-description "all the features so far"
             #:feed-updated/epoch-seconds (current-seconds)
             #:author-name "the lawnelephant staff"
             #:items 
             (map (lambda (fr) 
                    (let ((explanation (rec-prop fr 'explanation)))
                      (atom-item 
                       #:title (string-ellide explanation 40)
                       #:url (string-append (setting *WEB_APP_URL*) "feature/" (rec-id fr))
                       #:updated-epoch-seconds (rec-prop fr 'created-at)
                       #:content explanation)))
                  (get-feature-requests-newest))))

(define (delete-entry-view feat-req-rec)
  (** " "
      (web-link "[delete]" (body-as-url (req) (delete-rec! feat-req-rec) 
                                        (redirect-to (page-url adminified-index-page))))))

(define (mark-as-completed-view feat-req-rec)
  (** " "
      (web-link "[mark completed]" (body-as-url (req)
                                                (rec-set-prop! feat-req-rec 'completed #t)
                                                (store-rec! feat-req-rec)
                                                (redirect-to (page-url
                                                              adminified-index-page))))))

(define (base-design #:title (title "lawnelephant"))
  (design
   #:atom-feed-page feature-feed-page
   #:js '("http://yui.yahooapis.com/combo?2.6.0/build/yahoo-dom-event/yahoo-dom-event.js&2.6.0/build/element/element-beta-min.js&2.6.0/build/tabview/tabview-min.js" )
   #:css '("http://yui.yahooapis.com/combo?2.6.0/build/reset-fonts-grids/reset-fonts-grids.css&2.6.0/build/base/base-min.css&2.6.0/build/tabview/assets/skins/sam/tabview.css"
           "/css/main.css")
   #:title title))

