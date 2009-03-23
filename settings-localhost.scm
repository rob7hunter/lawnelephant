(require (planet "settings.scm" ("vegashacker" "leftparen.plt" 4 (= 1))))

(setting-set! *PORT* 8765)
;; use #f if you want to listen to all incoming IPs:
(setting-set! *LISTEN_IP* "127.0.0.1")
(setting-set! *WEB_APP_URL* "http://localhost:8765/")
;;(setting-set! *ALLOW_DEFINE_DEBUG* #t)
