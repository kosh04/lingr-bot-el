;;; lingr-bot.el    --- Chatbot on lingr        -*- lexical-binding: t -*-

;; Author: KOBAYASHI Shigeru (kosh) <shigeru.kb@gmamil.com> 
;; Version: 20151014.0
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
(require 'names)
(require 'time)

(define-namespace lingr-bot-

(defvar server-port 8080)
(defvar server-host "0.0.0.0")

(defun sandbox-eval (form)
  (let (;;(default-directory nil)
        (process-environment nil)
        (initial-environment nil)
        (exec-path nil)
        (shell-file-name "true")        ; command "do nothing"
        (load-path nil))
    (with-timeout (5 "Timeout.")
      (with-temp-buffer
        (condition-case e
            (eval form)
          (error (error-message-string e)))))))

(defun -dispatch-message (text)
  (cond
   ;; show version
   ((equal text "M-x emacs-version")
    emacs-version)

   ;; show uptime
   ((equal text "M-x uptime")
    (emacs-uptime))

   ;; !emacs EXPR
   ((string-match "^!emacs \\(.+\\)" text)
    (let ((msg (match-string 1 text)))
      (prin1-to-string
       (sandbox-eval (ignore-errors (read msg))))))

   ;; C-h f FUNCTION
   ((string-match "^C-h f \\(.+\\)" text)
    (let ((msg (match-string 1 text)))
      (when (functionp (intern msg))
        (documentation (intern msg)))))

   ;; C-h v VARIABLE
   ((string-match "^C-h v \\(.+\\)" text)
    (let ((msg (match-string 1 text)))      
      (documentation-property (intern msg) 'variable-documentation)))

   (t (ignore))))

(defun -parse-message (data)
  (let-alist (ignore-errors (json-read-from-string data))
    (when (equal .status "ok")
      (cl-loop for event across .events
               do (let-alist event
                    (when (equal .message.type "user")
                      (cl-return (-dispatch-message .message.text))))))))

(defun -pretty-format (text)
  "Pretty format TEXT for lingr message output."
  (--> (or text "")
       (s-replace "\s" "\u3000" it)
       (s-truncate (- 1000 3) it)))

(defun root-handler (httpcon)
  (elnode-http-start httpcon 200 `("Server" . ,(format "GNU Emacs %s" emacs-version)))
  (elnode-http-return httpcon "It works!"))

(defun bot-handler (httpcon)
  (elnode-method httpcon
    (POST
     ;; TODO: IP whitelist
     (let* ((http-body
             ;;(elnode--http-post-body httpcon)
             (caar (elnode-http-params httpcon)))
            (text (-parse-message http-body)))
       (elnode-http-start httpcon 200 '("Content-Type" . "text/plain; charset=utf-8"))
       (elnode-http-return httpcon (-pretty-format text))))
    (t
     (elnode-send-redirect httpcon "http://lingr.com/"))))

(defun httpd-dispatcher (httpcon)
  (elnode-dispatcher httpcon
                     `(("/lingr/" . ,#'bot-handler)
                       ("/" . ,#'root-handler))))

:autoload
(defun server-start (&optional port host)
  (interactive)
  (elnode-start #'httpd-dispatcher
                :port (or port server-port)
                :host (or host server-host)))

:autoload
(defun server-stop (&optional port)
  (interactive)
  (elnode-stop (or port server-port)))

:autoload
(defun server-restart ()
  (interactive)
  (server-stop)
  (server-start))

) ;; end namespace

(provide 'lingr-bot)

;;; lingr-bot.el ends here
