;; -*- lexical-binding: t; -*-
;;
;; This file runs as early as possible when starting the editor.
;; It mainly contians the bootstrapping code for the `straight.el`
;; package manager, and it sets up `use-package` integration
;; with it. For the main configuration, consult the `init.el` file.
;;
;; author:          Tim Baccaert <tim@baccaert.com>
;; git-url:         https://github.com/timplication/.emacs.d.git
;; license:         MIT
;; config-version:  0.1.0
;;

;; Test

(setq inhibit-x-resources t)
(setq inhibit-startup-buffer-menu t)

;;;;;;;;;;;;;;;;;;;;;;;;
;; Package Management ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Disable the native packaging system in Emacs in favor
;; of `straight.el` which we set up in `init.el`.
(setq package-enable-at-startup nil)

;; Bootstrap the `straight.el` package management functionality.
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

;; Integrate `straight.el` with `use-package`
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;;;;;;;;;;;;;;;;;;;;;;;
;; Window Management ;;
;;;;;;;;;;;;;;;;;;;;;;;

(setq initial-frame-alist '((horizontal-scroll-bars . nil)
			    (menu-bar-lines . 0)
			    (tool-bar-lines . 0)
			    (vertical-scroll-bars . nil)
			    (scroll-bar-width . 12)
			    (width . (text-pixels . 800))
			    (height . (text-pixels . 900))
			    (undecorated . t)
			    (fullscreen . maximized)))

(add-hook 'after-init-hook (lambda ()
			     (setq initial-frame-alist '((horizontal-scroll-bars . nil)
							 (menu-bar-lines . 0)
							 (tool-bar-lines . 0)
							 (vertical-scroll-bars . nil)
							 (scroll-bar-width . 12)
							 (width . (text-pixels . 800))
							 (height . (text-pixels . 900))
							 (undecorated . t)
							 (fullscreen . maximized)))))

(add-hook 'after-init-hook (lambda () (set-frame-name "home")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Startup Speed Optimization ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; c.f. https://github.com/protesilaos/dotfiles/blob/master/emacs/.emacs.d/early-init.el

(defvar emacs--file-name-handler-alist file-name-handler-alist)
(defvar emacs--vc-handled-backends vc-handled-backends)

(setq file-name-handler-alist nil
      vc-handled-backends nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 100 100 8)
                  gc-cons-percentage 0.1
                  file-name-handler-alist emacs--file-name-handler-alist
                  vc-handled-backends emacs--vc-handled-backends)))
