;;; setup.el

;; load unless using Cask

(require 'package)

(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(message "package archives configured added")

(package-initialize)
(message "packages initialized")

(package-refresh-contents)
(message "packages refreshed")

(package-install 'elnode)
(package-install 'cl-lib)
(package-install 'json)
(package-install 'let-alist)
(package-install 'names)
(package-install 's)
(message "require package installed")

(provide 'setup-elnode)
