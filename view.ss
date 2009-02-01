#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         "app.scm"
         "data.ss"
         "admin.ss")

(provide index-page-view
         feature-detail-page-view
         base-design
         )

(define (index-page-view)
  (page
   #:design (base-design)
   `(div ((id "doc"))
         (div ((id "hd"))
              (img ((src "/i/logo.jpg"))))
         (div ((id "bd"))
              (div ((id "requests"))
                   ,(form '((explanation "" long-text))
                          #:submit-label "Request a Feature"
                          #:init '((type . feature-request))))
              (ul ,@(map feature-req-view (get-feature-requests))))
         (div ((id "ft"))
              (ul ((class "simple"))
                  (li (a ((href "http://github.com/vegashacker/lawnelephant/tree/master")) "github"))
                  (li (a ((href "mailto:ask@lawnelephant.com"))
                         "ask@lawnelephant.com")))))))

(define (feature-detail-page-view feat)
  (page
   #:design (base-design)
   `(p ,(rec-prop feat 'explanation))))

(define (feature-req-view feat)
  `(li ,(rec-prop feat 'explanation)
       " " ,(web-link "[link]" (page-url feature-detail-page (rec-id feat)))
       ,(xexpr-if (in-admin-mode?)
                  (delete-entry-view feat))))

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
                                        (index-page-view)))))

(define (base-design #:title (title "lawnelephant"))
  (design
   #:atom-feed-page feature-feed-page
   #:css
   '("http://yui.yahooapis.com/combo?2.6.0/build/reset-fonts-grids/reset-fonts-grids.css"
     "/css/main.css")
   #:title title))
