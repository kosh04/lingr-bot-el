;;; lingr-bot-test.el

(require 'ert)

(load (expand-file-name "lingr-bot.el"))
(load (expand-file-name "elnode-patch.el"))

;; test bot command

(ert-deftest command/version ()
  (should (stringp (lingr-bot--dispatch-message "M-x emacs-version"))))

(ert-deftest command/uptime ()
  (should (stringp (lingr-bot--dispatch-message "M-x uptime"))))

(ert-deftest command/help-function ()
  (should (stringp (lingr-bot--dispatch-message "C-h f car")))
  (should (stringp (lingr-bot--dispatch-message "C-h f setf")))   ; macro
  (should (stringp (lingr-bot--dispatch-message "C-h f rplaca"))) ; alias
  (should (null (lingr-bot--dispatch-message "C-h f **unknown**"))))

(ert-deftest command/help-variable ()
  (should (stringp (lingr-bot--dispatch-message "C-h v load-path")))
  (should (stringp (lingr-bot--dispatch-message "C-h v argv")))
  (should (null (lingr-bot--dispatch-message "C-h v **unknown**"))))

(ert-deftest command/eval ()
  (should (string= (lingr-bot--dispatch-message "!emacs (= 1 1)") "t"))
  (should (string= (lingr-bot--dispatch-message "!emacs (= 1 0)") "nil"))
  (should (string= (lingr-bot--dispatch-message
                    "!emacs ((lambda (x &optional y) (cons x y)) 1 2)")
                   "(1 . 2)"))
  ;; XXX: shoud allow newline?
  (should (string= (lingr-bot--dispatch-message "!emacs (cons 1 \n 2)")
                   "nil")))

;; (ert t)
