#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         "app.scm"
         "data.ss"
         "social.ss"
         "admin.ss")


(provide index-page-view
         feature-detail-page-view
         base-design
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

(define standard-footer
  `(ul ((class "simple"))
       (li (a ((href "http://github.com/vegashacker/lawnelephant/tree/master")) "github"))
       (li (a ((href "http://blog.lawnelephant.com")) "blog"))
       (li (a ((href "mailto:ask@lawnelephant.com")) "ask@lawnelephant.com"))
       ;goog analytics really needs to be just before the closing body tag, but I don't know
       ;how to put it there just yet
      ,(raw-str goog-analytics)))

(define (index-page-view sesh #:form-view (form-markup request-feature-form-view))
  (page
   #:design (base-design)
   `(div ((id "doc"))
         (div ((id "hd"))
              (img ((src "/i/logo.jpg"))))
         (div ((id "bd"))
              (div ((id "requests"))
                   ,(form-markup sesh))
              (ul ,@(map (cut feature-req-view sesh <>) (get-feature-requests))))
         (div ((id "ft")) ,standard-footer))))

(define (request-feature-form-view sesh)
  (form '((explanation "" long-text))
        #:submit-label "Request a Feature"
        #:init '((type . feature-request))
        #:error-wrapper (lambda (error-form-view)
                          (index-page-view sesh #:form-view
                                           (lambda (sesh) error-form-view)))
        #:validate feature-request-validator))

(define (feature-detail-page-view feat)
  (let ((exp (rec-prop feat 'explanation)))
    (page
     #:design (base-design #:title (format "lawnelephant | ~A" (string-ellide exp 10)))
     `(div ((id "doc"))
           (div ((id "hd"))
                (span ((id "header")) 
                      ,(web-link "lawnelephant.com" (setting *WEB_APP_URL*))
                      " > feature details"))
           (div ((id "bd")) (p ,exp))
           (div ((id "ft")) ,standard-footer)))))

(define (feature-req-view sesh feat)
  `(li 
     (span ((class "explanation"))
           ,(feature-request-expl feat))
       (div ((class "explanation-rest"))
           ,(web-link "[link]" (page-url feature-detail-page (rec-id feat)))
           " "
           ,(xexpr-if (can-vote-on? sesh feat)
                      (** (web-link "[vote up]" (make-up-voter-url sesh feat))
                          " "))
           ,(format "~A pts " (vote-score feat))
           ,(xexpr-if (in-admin-mode?)
                      (delete-entry-view feat)))))

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
                               (get-feature-requests))))

(define (delete-entry-view feat-req-rec)
  (** " "
      (web-link "[delete]" (body-as-url (req) (delete-rec! feat-req-rec) 
                                        (redirect-to (page-url index-page))))))


(define (base-design #:title (title "lawnelephant"))
  (design
   #:atom-feed-page feature-feed-page
   #:css
   '("http://yui.yahooapis.com/combo?2.6.0/build/reset-fonts-grids/reset-fonts-grids.css"
     "/css/main.css")
   #:title title))


