;;; command/help

(require 'lingr-bot)
(require 'package)
(require 'cl-lib)
(require 'rx)

(cl-defun lingr-bot-command/describe-function (text &optional (symbol (intern (match-string 1 text))))
  (when (fboundp symbol)
    (documentation symbol)))

(cl-defun lingr-bot-command/describe-variable (text &optional (symbol (intern (match-string 1 text))))
  (documentation-property symbol 'variable-documentation))

(cl-defun lingr-bot-command/describe-package (text &optional (feature (intern (match-string 1 text))))
  (condition-case e
      (progn
        (save-window-excursion
          (describe-package feature))
        (with-current-buffer "*Help*"
          (buffer-string)))
    (error (format "Unknown package: %s" feature))))

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
