;;;;
;;;; Auto-generated Configuration Setup (i.e., `M-x customize')
;;;;

;; Make Emacs write its custom configuration to a separate file so
;; it does not clobber this manually written configuration.
    
(setq custom-file (locate-user-emacs-file "~/.emacs.d/custom.el"))
(load-file custom-file)

;;;;
;;;; Package Management
;;;;

;; Enable the MELPA package repository.

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; In case we are running this configuration on an older version of emacs,
;; we still have to enable `use-package' manually.
    
(when (< emacs-major-version 29)
  (unless (package-installed-p 'use-package)
    (unless package-archive-contents
      (package-refresh-contents))
    (package-install 'use-package)))

;; Disable warning display from the byte compiler during package installation.
;; If you need to verify it because of some issue, you can still get this info
;; from the buffer list yourself.
    
(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

;;;;
;;;; Theming and Styling
;;;;

;; Disable some of the GUI features such as tool bars,
;; scroll bars and menu bars.
    
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)

;; Stop the splash screen from showing.
   
(setq inhibit-startup-screen t)

;; Enable a custom theme.

(use-package catppuccin-theme
    :ensure t
    :config
    (setq catppuccin-flavor 'latte)
    (load-theme 'catppuccin :no-confirm-loading))

;; Select different fonts.

(let ((monospace-font "Iosevka Term SS08")
      (sans-serif-font "Iosevka Aile"))
  (set-face-attribute 'default nil
		      :family monospace-font
		      :height 160)
  (set-face-attribute 'fixed-pitch nil
		      :family monospace-font
		      :height 1.0)
  (set-face-attribute 'variable-pitch nil
		      :family sans-serif-font
		      :height 1.0))

;; Enable support for nerd-icons.

(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (add-hook 'marginalia-mode-hook
	    #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package nerd-icons-dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))

;;;;
;;;; Disable General Emacs Jank
;;;;

;; Disable the bell sound on things like `C-g' when
;; cancelling a command.

(setq ring-bell-function 'ignore)

;; Disable backup files.

(setq make-backup-files nil)

;; Make `C-g' exit out of more buffers where the default
;; is normally `<ESC> <ESC> <ESC>' (which is annoying).

(defun timplication/just-quit-already ()
  "The default Emacs `keyboard-quit' does not actually
   close things such as the minibuffer or disable region selects.
   This function enables that."
  (interactive)
  (cond
   ;; region
   ((region-active-p)
    (keyboard-quit))
   ;; minibuffer
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   ;; default behavior
   (t
    (keyboard-quit))))

(define-key global-map (kbd "C-g") #'timplication/just-quit-already)

;;;;
;;;; Minibuffer Configuration
;;;;

;; Assuming we are on a modern emacs version,
;; enable the built-in vertical fido mode for
;; a vertical list of completions in the minibuffer.
;; This also enables the packages `marginalia' and `orderless'
;; which respectively give inline documentation and
;; order-irrelevant regex matching of whatever you
;; type into the minibuffer.

(when (>= emacs-major-version 29)
  (fido-vertical-mode)
  
  ;; Orderless Configuration
  (use-package orderless
    :ensure t
    :custom
    (completion-styles '(orderless basic))
    (completion-category-overrides nil)
    (completion-category-defaults nil))
  
  ;; Marginalia Configuration
  (use-package marginalia
    :ensure t
    :init (marginalia-mode)))

;;;;
;;;; Code Completion
;;;;

;; Corfu is a code-completion engine, it auto-completes based on
;; things like the language server protocol (LSP) depending on the
;; language you are using.

(use-package corfu
  :ensure t
  :bind (:map corfu-map ("<tab>" . corfu-complete))
  :custom
  (tab-always-indent 'complete)
  (corfu-preview-current nil)
  (corfu-min-width 20)
  (corfu-popupinfo-delay '(1.25 . 0.5))
  :config
  (with-eval-after-load 'savehist
    (corfu-history-mode 1)
    (add-to-list 'savehist-additional-variables 'corfu-history))
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode 1))

;;;;
;;;; Window Management
;;;;

;; Use `M-o' instead of `C-x o' to facilitate faster window switching.

(global-set-key (kbd "M-o") 'other-window)

;;;;
;;;; Language Specific - Rust
;;;;

(use-package rust-mode
  :ensure t
  :mode ("\\.rs\\'" . rust-mode)
  :custom
  (rust-format-on-save t)
  (rust-indent-where-clause t)
  (rust-format-show-buffer nil))

(use-package cargo-mode
  :ensure t
  :custom
  (compilation-scroll-output t)
  :hook
  (rust-mode . cargo-minor-mode))
    
;;;;
;;;; Language Specific - LaTeX
;;;;

;; PDF Support

(use-package pdf-tools
  :ensure t
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :custom
  (pdf-view-display-size 'fit-page)
  :config
  (pdf-loader-install)
  (add-hook 'pdf-view-mode-hook #'pdf-view-roll-minor-mode))

;; TeX Support

(use-package auctex
  :ensure t
  :mode ("\\.tex\\'" . LaTeX-mode)
  :custom
  (TeX-view-program-selection '((output-pdf "PDF Tools")))
  (TeX-source-correlate-mode t)
  (TeX-source-correlate-method 'synctex)
  (TeX-source-correlate-start-server t)
  (TeX-engine 'xetex)
  (TeX-output-dir "build")
  :config
  (setq-default TeX-master nil)
  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer))
 
