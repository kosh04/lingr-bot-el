;;; command/eval

(require 'lingr-bot)
(require 'rx)
(require 'cl-lib)

(defun lingr-bot-command/eval-in-sandbox (form)
  (lingr-bot--log "eval: %S" form)
  (let (;;(default-directory nil)
        (process-environment nil)
        (initial-environment nil)
        (exec-path nil)
        (shell-file-name "true")        ; command DO NOTHING
        (load-path nil))
    (with-timeout (5 "Timeout.")
      (with-temp-buffer
        (condition-case e
            (eval form)
          (error (error-message-string e)))))))

(cl-defun lingr-bot-command/eval (text &optional (msg (match-string 1 text)))
  (condition-case e
      (prin1-to-string
       (lingr-bot-command/eval-in-sandbox (read msg)))
    (error (error-message-string e))))

;; !emacs EXPR (should be one-line)
(define-lingr-bot-command
  (rx bol "!emacs" (+ space) (group (+ any)))
  #'lingr-bot-command/eval)
