#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 5 (= 1)))
         )

(provide
  base-design
  li-a
  goog-analytics
  standard-footer
  div-id
  div-footer
  )

(setting-set! *APP_VERSION* 2)

(define (div-id id rest)
  `(div ((id ,id)) ,rest))

(define (div-footer)
  (div-id "ft" standard-footer))

(define (base-design #:title (title "lawnelephant"))
  (design
    #:raw-header '("<link rel=\"icon\" href=\"/favicon.png\">")
   #:js (list "http://ajax.googleapis.com/ajax/libs/jquery/1.3.1/jquery.min.js"
              (format "/scripts/init-~A.js" (setting *APP_VERSION*)))
   #:css (list (format "/css/main-~A.css" (setting *APP_VERSION*)))
   #:title title))

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
  `(ul ((class "simple"))
       ,(li-a "http://blog.lawnelephant.com/post/74637624/introducing-lawnelephant-com" "about")
       ,(li-a "http://blog.lawnelephant.com" "blog")
       ,(li-a "http://github.com/vegashacker/lawnelephant/tree/master" "source code")
       ,(li-a "mailto:ask@lawnelephant.com" "ask@lawnelephant.com")
       ,(li-a "http://twitter.com/lawnelephant" "@lawnelephant")
       ,(raw-str goog-analytics)))
