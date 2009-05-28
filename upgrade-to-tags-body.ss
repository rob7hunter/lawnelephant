(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 5 (= 1))))

(define feature-requests
  (load-where #:type 'feature-request))

(for-each (lambda (fr)
            (rec-set-prop! fr 'body (string-append (rec-prop fr 'explanation)
                                                   " #feature"
                                                   (if (rec-prop fr 'completed)
                                                       " #complete"
                                                       "")))
            (rec-set-prop! fr 'type 'post)
            (rec-remove-prop! fr 'explanation)
            (rec-remove-prop! fr 'completed)
            (store-rec! fr))
          feature-requests)