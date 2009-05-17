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

(define (tag-subst tag-str)
  (web-link tag-str
            (format "/tag/~A" (second (regexp-match "#(.+)" tag-str)))))
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


