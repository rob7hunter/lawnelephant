#lang scheme/base

(require (planet "util.scm" ("vegashacker" "leftparen.plt" 5 (= 0)))
         (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 0)))
         "tags.ss"
         )

(provide markup-body
         tag-subst 
         )

;; This URL finding code to eventually go in LeftParen...

;; Notes on the regexps:
;;   (?:...) indicates not to count the grouping as a match
;;   all backslashed codes need to be double-backslashed in the string
;;   \b is a word boundary
;;   \. is a dot, not any character
;;  in a character range, ^ (not) indicates none of the chars given, not just the first

;; Pregexp vs regexp notes:
;;  \\b doesn't work in regexp
;;  \\w doesn't work in regexp

(define REGEXP_W "A-Za-z0-9_")

(define URL_PROTOCOL_REGEXP (format "(?:http|https|feed):\\/\\/(?:[A-Za-z][~A]*\\.)?"
                                    REGEXP_W))

;; second level domain dot domain and the rest to the top level domain
(define URL_DOMAIN_REGEXP (format "[~A][-~A]*(?:\\.[~A][-~A]*)"
                                  REGEXP_W
                                  REGEXP_W
                                  REGEXP_W
                                  REGEXP_W))

;; the second colon is a literal colon; this is optional
(define URL_OPTIONAL_PORT_REGEXP "(?::\\d+)?")

(define URL_FILENAME_PATH_CHARS "[0-9a-zA-Z_!~*'().;?:@&=+$,%#-]")

;; skip  . ! ? ' ( ) : ; -
;; why?  because these are likely legitamate punctuation in body text.
(define URL_ENDING_CHARS "[0-9a-zA-Z_~*@&=+$,%#]")

;; either nothing, a plain slash, or a series of path/files which ends with a ending char
(define URL_SUBDIR_REGEXP (format "(?:(?:(?:/~A+)+)~A|/)?"
                                  URL_FILENAME_PATH_CHARS
                                  URL_ENDING_CHARS))

(define URL_REGEXP (string-append URL_PROTOCOL_REGEXP
                                  URL_DOMAIN_REGEXP
                                  URL_OPTIONAL_PORT_REGEXP
                                  URL_SUBDIR_REGEXP))

;; this marks up tags. Does it belong in tags.ss or markup.ss?
;; 
;; on the tag clouds we don't want to show hashes
;; but in a post we do (because it is educational)

(define (tag-subst tag-str 
                   #:supress-hash (supress? #f)
                   #:tag-list (tags #f))
  (let* ((str (second (regexp-match "#(.+)" tag-str)))
         (hash-decorator (if supress? "" "#"))
         (link (if tags 
                 (format "/tag/~A" (tags-to-url (make-new-taglist str tags))) 
                 (format "/tag/~A" str))))
    `(span ,(xexpr-if (and tags (member str tags)) 
                      `((class "activetag")))
           ,hash-decorator 
           ,(web-link str link))))


;; (make-new-taglist "cheese" '("beer" "coke")) -> '("cheese" "beer" "coke")
;; (make-new-taglist "beer" '("beer" "coke")) -> '("coke")

(define (make-new-taglist tag tags)
  (if (member tag tags)
    (remove tag tags)
    (sort (append (list tag) tags) string<=?)))

;; '("feature" "complete") -> "feature+list"

(define (tags-to-url tags)
  (cond
    ((null? tags) "")
    ((null? (cdr tags)) (car tags))
    (else (string-append (car tags) "+" (tags-to-url (cdr tags))))))


;; handles newlines, tags and URLs...

(define (markup-body stri)
  (let ((str (regexp-replace #px"[\n\r]*$" stri "")))

    (define NEWLINE_REGEXP "[\n\r][\n\r]|[\n\r]")

    (define (newline-subst newline-str)
      `(br))

    (define (url-subst url)
      (web-link url url))

    (define (urlify str)
      (apply ** (regexp-replace-in-list* URL_REGEXP
                                         str
                                         url-subst
                                         )))

    (define (newlineify str) 
      (apply ** (regexp-replace-in-list* NEWLINE_REGEXP 
                                         str 
                                         newline-subst
                                         urlify
                                         )))

    (define (tagify str) 
      (apply ** (regexp-replace-in-list* TAG_REGEXP ; via tag.ss 
                                         str 
                                         tag-subst  ; do this to matches
                                         newlineify ; do this to non-matches
                                         )))
    (tagify str)))


