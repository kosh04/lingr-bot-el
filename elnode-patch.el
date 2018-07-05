;;; elnode-patch.el

(require 'elnode)
(require 'nadvice)

;; https://github.com/nicferrier/elnode/pull/101
(defun elnode--http-send-bytes (f httpcon text)
  "[user] monkey patch for `elnode-http-send-string' as raw byte senquence."
  (funcall f httpcon (encode-coding-string text 'raw-text)))  

(advice-add 'elnode-http-send-string :around 'elnode--http-send-bytes)

;; FIXME: where Elnode API to get raw http body is?
(defun elnode-raw-http-body (httpcon)
  "[user] Return raw http body string in HTTPCON session."
  (when (process-live-p httpcon)
    (elnode--http-post-body httpcon)))

(defun elnode/make-service (host port service-mappings request-handler defer-mode)
  "Make an actual server TCP or Unix PORT.

If PORT is a number then a TCP port is made on the specified HOST
on the PORT.

If PORT is a string a Unix socket is made in \"/tmp/\" and HOST
is ignored."
  (let* ((name (format "*elnode-webserver-%s:%s*" host port))
         (an-buf (get-buffer-create name))
         (unix-sock-file-name (unless (numberp port) (concat "/tmp/" port)))
         (proc-args
          (list
           :name name
           :buffer an-buf
           :server (if (numberp port) 300 't)
           ;;:nowait 't
           :host (cond
                   ((not (numberp port)) nil)
                   ((equal host "localhost") 'local)
                   ((equal host "*") nil)
                   (t host))
           :coding '(raw-text-unix . raw-text-unix)
           :family (if (numberp port) 'ipv4 'local)
           :service (if (numberp port) port unix-sock-file-name)
           :filter 'elnode--filter
           ;;:sentinel 'elnode--sentinel
           :log 'elnode/proc-log))
         (proc (apply 'make-network-process proc-args)))
    (elnode/con-put proc
      :elnode-service-map service-mappings
      :elnode-http-handler request-handler
      :elnode-defer-mode defer-mode)
    proc))

(provide 'elnode-patch)
