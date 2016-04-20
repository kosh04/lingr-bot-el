;;; lingr-bot.el --- Chatbot on lingr  -*- lexical-binding: t -*-

;; Author: KOBAYASHI Shigeru (kosh) <shigeru.kb@gmamil.com> 
;; Version: 20160420.0
;; Created: 12 Oct 2015
;; License: MIT

;; Keywords: irc bot
;; Prefix: lingr-bot
;; Separator: -

;;; Commentary:

;;; Code:

(require 'cl-lib)
(require 'elnode)
(require 'json)
(require 'dash)
(require 's)
(require 'let-alist)
(require 'time)

(defvar lingr-bot-server-port 8080)
(defvar lingr-bot-server-host "0.0.0.0")

(defvar lingr-bot-default-page-url "http://lingr.com/bot/emacs24")

(defun lingr-bot--log (fmt &rest args)
  "Write simple log message."
  (message "[lingr-bot] %s" (apply #'format fmt args)))

(defvar lingr-bot-commands nil
  "Bot Commands. its asssoc list. (regexp . command)")

(defun define-lingr-bot-command (regexp function)
  (add-to-list 'lingr-bot-commands (cons regexp function) t))

(defun lingr-bot--dispatch-message (text)
  (cl-loop for (regexp . command) in lingr-bot-commands
           if (string-match regexp text)
           return (funcall command text)))

(defun lingr-bot--parse-message (data)
  (let-alist (ignore-errors (json-read-from-string data))
    (when (equal .status "ok")
      (cl-loop for event across .events
               do (let-alist event
                    (when (equal .message.type "user")
                      (cl-return (lingr-bot--dispatch-message .message.text))))))))

(defun lingr-bot--pretty-format (text)
  "Pretty format TEXT for lingr message output."
  (--> (or text "")
       (s-replace "\s" "\u00a0" it)
       (s-truncate (- 1000 3) it)))

(defun lingr-bot-root-handler (httpcon)
  (elnode-http-start httpcon 200 `("Server" . ,(format "GNU Emacs %s" emacs-version)))
  (elnode-http-return httpcon "It works!"))

(defun lingr-bot-bot-handler (httpcon)
  (elnode-method httpcon
    (POST
     ;; TODO: IP whitelist
     (let* ((http-body-raw (elnode-raw-http-body httpcon))
            (http-body (decode-coding-string http-body-raw 'utf-8))
            (text (condition-case e
                      (lingr-bot--parse-message http-body)
                    (error
                     (lingr-bot--log "Fail parse-message: %S" e)
                     nil))))
       (elnode-http-start httpcon 200 '("Content-Type" . "text/plain; charset=utf-8"))
       (when text
         (elnode-http-send-string httpcon (lingr-bot--pretty-format text)))
       (elnode-http-return httpcon)))
    (t
     (elnode-send-redirect httpcon lingr-bot-default-page-url))))

(defvar lingr-bot-mapping
  `(("/lingr/" . ,#'lingr-bot-bot-handler)
    ("/" . ,#'lingr-bot-root-handler)))

(defun lingr-bot-httpd-dispatcher (httpcon)
  (elnode-dispatcher httpcon lingr-bot-mapping))

;;;###autoload
(defun lingr-bot-server-start (&optional port host)
  (interactive)
  (elnode-start #'lingr-bot-httpd-dispatcher
                :port (or port lingr-bot-server-port)
                :host (or host lingr-bot-server-host)))

;;;###autoload
(defun lingr-bot-server-stop (&optional port)
  (interactive)
  (elnode-stop (or port lingr-bot-server-port)))

;;;###autoload
(defun lingr-bot-server-restart ()
  (interactive)
  (lingr-bot-server-stop)
  (lingr-bot-server-start))

(provide 'lingr-bot)

;;; lingr-bot.el ends here
