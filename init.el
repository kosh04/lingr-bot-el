;;; start-elnode.el             -*- lexical-binding: t -*-

(unless (package-installed-p 'elnode)
  (load "setup-elnode"))

(load "lingr-bot")

(lingr-bot-server-start
 (string-to-number (or (getenv "PORT") "8080")))

(while t
  (accept-process-output nil 1.0))

;;; End
