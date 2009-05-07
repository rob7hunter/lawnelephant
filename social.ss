#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 0)))
         "app.scm"
         )

(provide can-vote-on?
         make-voter-url
         vote-score
         )

;; voting

;;XXX DRY alert
(define (can-vote-on? sesh feat)
  (not (or (member (session-id sesh) (rec-child-prop feat 'votes))
           (member (session-id sesh) (rec-child-prop feat 'down-votes)))))

(define (make-voter-url sesh feat direction)
  (let ((vote-fn (if (string=? "up" direction) 
                   up-vote! 
                   down-vote!)))
    (body-as-url (req)
                 (vote-fn sesh feat)
                 (redirect-to (page-url index-page)))))

(define (make-gen-voter key)
  (lambda (sesh feat)
    (rec-add-list-prop-elt! feat key (session-id sesh))
    (store-rec! feat)))

(define up-vote! (make-gen-voter 'votes))
(define down-vote! (make-gen-voter 'down-votes))

(define (vote-score feat)
  (- 
    (+ 1 (length (rec-child-prop feat 'votes)))
    (length (rec-child-prop feat 'down-votes))))




