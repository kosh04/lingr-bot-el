;;; command/help

(require 'lingr-bot)
(require 'package)
(require 'cl-lib)
(require 'rx)
(require 'json)
(require 'url-handlers)
(require 'dash)
(require 'let-alist)

(cl-defun lingr-bot-command/describe-function (text &optional (symbol (intern (match-string 1 text))))
  (if (fboundp symbol)
      (documentation symbol)
    (format "Unknown function: %s" symbol)))

(cl-defun lingr-bot-command/describe-variable (text &optional (symbol (intern (match-string 1 text))))
  (if (boundp symbol)
      (documentation-property symbol 'variable-documentation)
    (format "Unknown variable: %s" symbol)))

(defvar lingr-bot-command/-package-archive
  (json-read-from-string
   (with-temp-buffer
     (url-insert-file-contents "http://melpa.org/archive.json")
     (buffer-string))))

(cl-defun lingr-bot-command/describe-package (text &optional (feature (intern (match-string 1 text))))
  ;; (condition-case e
  ;;     (progn
  ;;       (save-window-excursion
  ;;         (describe-package feature))
  ;;       (with-current-buffer "*Help*"
  ;;         (buffer-string)))
  ;;   (error (format "Unknown package: %s" feature)))
  (or (--when-let (assoc feature lingr-bot-command/-package-archive)
        (let-alist it
          (format "%s: %s\n%s"
                  feature .desc
                  (or .props.url (format "https://melpa.org/#/%s" feature)))))
      (format "Unknown package: %s" feature))
  )

;; C-h f FUNCTION
(define-lingr-bot-command
  (rx bol "C-h" (+ space) "f" (+ space) (group symbol-start (+ any) symbol-end))
  #'lingr-bot-command/describe-function)

;; C-h v VARIABLE
(define-lingr-bot-command
  (rx bol "C-h" (+ space) "v" (+ space) (group symbol-start (+ any) symbol-end))
  #'lingr-bot-command/describe-variable)

;; C-h P PACKAGE
(define-lingr-bot-command
  (rx bol "C-h" (+ space) "P" (+ space) (group symbol-start (+ any) symbol-end))
  #'lingr-bot-command/describe-package)
