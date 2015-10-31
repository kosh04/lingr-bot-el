;;; elnode-patch.el

(require 'elnode)
(require 'nadvice)

;; https://github.com/nicferrier/elnode/pull/101
(defun elnode--http-send-bytes (f httpcon text)
  "[user] monkey patch for `elnode-http-send-string' as raw byte senquence."
  (funcall f httpcon (encode-coding-string text 'raw-text)))  

(advice-add 'elnode-http-send-string :around 'elnode--http-send-bytes)
