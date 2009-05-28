(require (planet "settings.scm" ("vegashacker" "leftparen.plt" 5 (= 1))))

(setting-set! *PORT* 1123)
;; use #f if you want to listen to all incoming IPs:
(setting-set! *LISTEN_IP* #f)
(setting-set! *WEB_APP_URL* "http://lawnelephant.com/")
(setting-set! *PATH_TO_DATA* "/home/rob/le-prod-code/prod-data")
