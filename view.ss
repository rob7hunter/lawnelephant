#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         "data.ss"
         "admin.ss")

(provide index-page-view
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
              (ul ,@(map (lambda (fr) `(li ,(rec-prop fr 'explanation)
                                           ,(xexpr-if (in-admin-mode?)
                                                      (delete-entry-view fr))))
                         (get-feature-requests))))
         (div ((id "ft"))
              (ul ((class "simple"))
                  (li (a ((href "http://github.com/vegashacker/lawnelephant/tree/master")) "github"))
                  (li (a ((href "mailto:ask@lawnelephant.com"))
                         "ask@lawnelephant.com")))))))

(define (delete-entry-view feat-req-rec)
  (** " "
      (web-link "[delete]" (body-as-url (req) (delete-rec! feat-req-rec) 
                                        (index-page-view)))))

(define (base-design #:title (title "lawnelephant"))
  (design
   #:css
   '("http://yui.yahooapis.com/combo?2.6.0/build/reset-fonts-grids/reset-fonts-grids.css"
     "/css/main.css")
   #:title title))
