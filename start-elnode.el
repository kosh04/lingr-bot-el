;;; start-elnode.el             -*- lexical-binding: t -*-

(when load-file-name
  (add-to-list 'load-path (file-name-directory load-file-name)))

;;(load "setup-elnode")
(load "lingr-bot")

(let ((port (string-to-number (or (getenv "PORT") "8080"))))
  (lingr-bot-server-start port))

(while t
  (accept-process-output nil 1.0))

;;; End
