#lang scheme/base

(provide
  goog-analytics
  standard-footer
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
  `(ul ((class "simple"))
       ,(li-a "http://github.com/vegashacker/lawnelephant/tree/master" "github")
       ,(li-a "http://blog.lawnelephant.com" "blog")
       ,(li-a "mailto:ask@lawnelephant.com" "ask@lawnelephant.com")
       ;; XXX goog analytics really needs to be just before the closing body tag, but I
       ;; don't know how to put it there just yet
      ,(raw-str goog-analytics)))
