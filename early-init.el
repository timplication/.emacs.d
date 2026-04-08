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
