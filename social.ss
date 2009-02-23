#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         "app.scm"
         )

(provide can-vote-on?
         make-up-voter-url
         vote-score
         )

;; voting

(define (can-vote-on? sesh feat)
  (not (member (session-id sesh) (rec-child-prop feat 'votes))))

(define (make-up-voter-url sesh feat)
  (body-as-url (req)
               (up-vote! sesh feat)
               (redirect-to (page-url index-page))))

(define (up-vote! sesh feat)
  (rec-add-list-prop-elt! feat 'votes (session-id sesh))
  (store-rec! feat))

(define (vote-score feat)
  (+ 1 (length (rec-child-prop feat 'votes))))
