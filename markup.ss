#lang scheme/base

(require (planet "util.scm" ("vegashacker" "leftparen.plt" 5 (= 0)))
         (planet "leftparen.scm" ("vegashacker" "leftparen.plt" 5 (= 0)))
         )

(provide markup-body
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

;; plucks out hastags from text. 
;; under development

(define TAG-REGEXP #px"((?<=^)|(?<=[[:blank:]]))#[A-Za-z0-9]+")

(define (markup-tags str)
    (regexp-replace-in-list* TAG-REGEXP str
                             string-upcase))

;; handles newlines and URLs...
(define (markup-body str)
  
  (define (newline-replace str)
    (regexp-replace-in-list* "[\n\r][\n\r]|[\n\r]" str
                             (lambda (newline) '(br))))
  (define (url-replace str)
    (regexp-replace-in-list* URL_REGEXP str
                             (lambda (url) (list (web-link url url)))
                             newline-replace))
  (let ((xexpr-lst (url-replace str)))
    (apply ** (concatenate xexpr-lst))))

