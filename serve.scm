(require (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 1)))
         "app.scm"
         "main.scm")

(load-server-settings)

(serve my-app)
