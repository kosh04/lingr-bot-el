;;; lingr-bot.el	-*- lexical-binding: t -*-

;; Version: 20151012.0
;; Keywords: chat bot
;; Prefix: lingr-bot
;; Separator: -

;;; Code:

(require 'cl-lib)
(require 'elnode)
(require 'json)
(require 's)
(require 'let-alist)
(require 'names)
(require 'time)

(require 'server)
(setq server-name "elnode-webserver")
(setq server-use-tcp t)
(server-start)

(define-namespace lingr-bot-

:autoload
(defvar server-port 8080)
(defvar server-host "0.0.0.0")

(defun sandbox-eval (form)
  (let (;;(default-directory nil)
        (process-environment nil)
        (initial-environment nil)
        (shell-file-name "true")        ; "do nothing" command
        (load-path nil))
    (condition-case e
        (eval form)
      (error (error-message-string e)))))

(defun -dispatch-message (text)
  (cond
   ;; ?emacs version
   ((equal text "?emacs version") emacs-version)

   ;; !emacs EXPR
   ((string-match "^!emacs \\(.+\\)" text)
    (let ((msg (match-string 1 text)))
      (prin1-to-string
       (sandbox-eval (ignore-errors (read msg))))))

   ;; C-h f FUNCTION
   ((string-match "^C-h f \\(.+\\)" text)
    (let ((msg (match-string 1 text)))
      (documentation (intern msg))))

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

(defun root-handler (httpcon)
  (elnode-http-start httpcon 200 `("Server" . ,(format "GNU Emacs %s" emacs-version)))
  (elnode-http-return httpcon "It works!"))

(defun bot-handler (httpcon)
  (elnode-method httpcon
    (POST
     ;; TODO: IP whitelist
     (let ((http-body (elnode--http-post-body httpcon)))
       (elnode-http-start httpcon 200 '("Content-Type" . "text/plain; charset=utf-8"))
       (elnode-http-return httpcon (s-truncate (- 1000 3) (-parse-message http-body)))))
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

;;; lingr-bot.el ends here.
