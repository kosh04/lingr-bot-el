;;; setup.el

;; load unless using Cask

(require 'nsm)
(require 'package)

(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(message "package archives configured added")

(package-initialize)
(message "packages initialized")

;; FIXME: avoid secutiry connection issue in marmalade-repo.org:443 (emacs-26.1 -lgnutls)
(let ((network-security-level 'low))
  (package-refresh-contents))
(message "packages refreshed")

(package-install 'elnode)
(package-install 'cl-lib)
(package-install 'json)
(package-install 'let-alist)
(package-install 'names)
(package-install 'dash)
(package-install 's)
(message "require package installed")

(provide 'setup-elnode)
