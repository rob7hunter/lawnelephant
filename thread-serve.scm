(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 0)))
         "app.scm"
         "main.scm")

(load-server-settings)

(thread (lambda () (serve my-app)))
