#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 0)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 5 (= 0)))
         )

(provide
  base-design
  li-a
  goog-analytics
  standard-footer
  )



(define (base-design #:title (title "lawnelephant"))
  (design
    #:raw-header '("<link rel=\"icon\" href=\"/favicon.png\">")
   #:js '("http://ajax.googleapis.com/ajax/libs/jquery/1.3.1/jquery.min.js"
          "scripts/init.js")
  ; #:css '("http://yui.yahooapis.com/combo?2.6.0/build/reset-fonts-grids/reset-fonts-grids.css&2.6.0/build/base/base-min.css&2.6.0/build/tabview/assets/skins/sam/tabview.css"
   #:css '( "/css/main.css")
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
