;;; start-elnode.el

(or (locate-library "elnode")
    (load "setup-elnode"))

(load "elnode-patch")

(load "lingr-bot")

(load "command/eval")
(load "command/help")
(load "command/uptime")
(load "command/version")

(setq lingr-bot-server-port
      (string-to-number (or (getenv "PORT") "8080")))

(lingr-bot-server-start)

(while t
  (accept-process-output nil 1.0))

;;; End
