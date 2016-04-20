;; package: lingr-bot-command

(require 'lingr-bot)
(require 'rx)

(defun lingr-bot-command/version (text)
  (emacs-version))

(define-lingr-bot-command
  (rx bol "M-x" (+ space) "emacs-version")
  #'lingr-bot-command/version)
