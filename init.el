;;; General Settings

;; Make Emacs write its custom configuration to a separate file so
;; it does not clobber this manually written configuration.
(setq custom-file "~/.emacs.d/custom.el")

;; Disable some of the GUI features that I do not use.
(tool-bar-mode 0)
(scroll-bar-mode 0)
(menu-bar-mode 0)

;; Disable the bell sound on things like C-g when cancelling a command.
(setq ring-bell-function 'ignore)

;; Display line numbers.
(add-hook 'prog-mode-hook (lambda () (display-line-numbers-mode 1)))
(add-hook 'text-mode-hook (lambda () (display-line-numbers-mode 1)))

;; Display line and column numbers on the modeline
(line-number-mode)
(column-number-mode)

;;;; Package Management

;; Enable the MELPA package repository.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Enable straight.el reproducible package management.
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))


;;;; Theming

;; Configure theme, style, fonts, etc.
(straight-use-package 'catppuccin-theme)
(load-theme 'catppuccin :no-confirm)
(setq catppuccin-flavor 'frappe)
(catppuccin-reload)

(set-frame-font "Iosevka Term SS08 18" nil t)


;;;; Other

;; Completion engine
(fido-vertical-mode)

(straight-use-package 'orderless)

(defun icomplete-styles ()
  (setq-local completion-styles '(orderless)))
(add-hook 'icomplete-minibuffer-setup-hook 'icomplete-styles)

;; PDF Support

(straight-use-package 'pdf-tools)

(pdf-loader-install)

(add-hook 'pdf-view-mode-hook (lambda ()
				(display-line-numbers-mode -1)
				(pdf-view-roll-minor-mode)))


;; TeX Support

(straight-use-package 'auctex)

(add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)

(setq TeX-view-program-selection '((output-pdf "PDF Tools"))
      TeX-source-correlate-start-server t
      TeX-engine 'xetex
      TeX-output-dir "build"
      TeX-command-default "LaTeXMk"
      TeX-auto-save t
      TeX-parse-self t)

(setq-default TeX-master nil)

;;;; Key Bindings

;; Change the default buffer list to use `ibuffer` instead.
(global-set-key [remap list-buffers] 'ibuffer)

;; Use 'M-o' instead of 'C-x o' to facilitate faster window switching.
(global-set-key (kbd "M-o") 'other-window)
