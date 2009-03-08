#lang scheme/base

(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         (planet "util.scm" ("vegashacker" "leftparen.plt" 4 (= 1)))
         )
(provide
  base-design
  li-a
  ;goog-analytics
  ;standard-footer
  )

(define (base-design #:title (title "lawnelephant"))
  (design
   ;#:atom-feed-page feature-feed-page
   #:js '("http://yui.yahooapis.com/combo?2.6.0/build/yahoo-dom-event/yahoo-dom-event.js&2.6.0/build/element/element-beta-min.js&2.6.0/build/tabview/tabview-min.js")
   #:css '("http://yui.yahooapis.com/combo?2.6.0/build/reset-fonts-grids/reset-fonts-grids.css&2.6.0/build/base/base-min.css&2.6.0/build/tabview/assets/skins/sam/tabview.css"
           "/css/main.css")
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
       ,(li-a "http://github.com/vegashacker/lawnelephant/tree/master" "github")
       ,(li-a "http://blog.lawnelephant.com" "blog")
       ,(li-a "mailto:ask@lawnelephant.com" "ask@lawnelephant.com")
       ;; XXX goog analytics really needs to be just before the closing body tag, but I
       ;; don't know how to put it there just yet
      ,(raw-str goog-analytics)))