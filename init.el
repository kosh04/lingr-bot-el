;;; start-elnode.el

(or (locate-library "elnode")
    (load "setup-elnode"))

(load "elnode-patch")

(load "lingr-bot")

(lingr-bot-server-start
 (string-to-number (or (getenv "PORT") "8080")))

(while t
  (accept-process-output nil 1.0))

;;; End
