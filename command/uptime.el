;; package: lingr-bot-command

(require 'lingr-bot)
(require 'rx)

(defun lingr-bot-command/uptime (text)
  (emacs-uptime))

(define-lingr-bot-command
  (rx bol "M-x" (+ space) "uptime")
  #'lingr-bot-command/uptime)
