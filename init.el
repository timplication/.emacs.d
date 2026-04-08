;; -*- lexical-binding: t; -*-
;;
;; The above setting causes Elisp to use lexical scoping, which
;; slightly improves the performance of the editor. And I personally
;; find it more intuitive than dynamic scoping.
;;
;; Anyway, this is my personal Emacs configuration. I am using a
;; version of Emacs that I compiled myself on each of the
;; machines I use, for which I provide the compile flags
;; below. This is mostly because I want to make use of the
;; latest features such as JIT-compilation of Elisp and
;; tree sitter support. This file starts with a number of
;; function definitions, the rest of the packages is
;; configured entirely within `use-package` macros.
;;
;; author:          Tim Baccaert <tim@baccaert.com>
;; git-url:         <https://github.com/timplication/.emacs.d.git>
;; license:         MIT
;; config-version:  0.1.0
;; emacs-version:   31.0.50
;; compile-flags:   --with-native-compilation \
;;                  --with-tree-sitter \
;;                  --with-pgtk \
;;                  --with-mailutils \
;;                  'CFLAGS=-O3 -march=native'
;;

;;;;;;;;;;;;;;;;;;;;;;
;; Custom Functions ;;
;;;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General Emacs Settings ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package emacs
  :init
  ;; Make Emacs write its custom configuration to a separate file so
  ;; it does not clobber this manually written configuration.
  (setq custom-file (locate-user-emacs-file "~/.emacs.d/custom.el"))
  (load-file custom-file)

  ;; Disable some of the GUI features such as tool bars,
  ;; scroll bars and menu bars.
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (menu-bar-mode -1)

  ;; Stop the default splash screen from showing up. 
  (setq inhibit-startup-screen t)
  
  ;; Configure different fonts.
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
  
  ;; Set Line Numbers
  (setq display-line-numbers 'relative)
  (setq-default display-line-numbers-type 'visual
		display-line-numbers-current-absolute t
		display-line-numbers-widen t)

  (add-hook 'prog-mode-hook (lambda ()
                              (display-line-numbers-mode)
                              ;; enable spellchecker in comments
                              (flyspell-prog-mode)))

  (add-hook 'text-mode-hook (lambda ()
                              (display-line-numbers-mode)
                              ;; enable spellchecker globally
                              (flyspell-mode)))

  ;; Indent with spaces instead of tabs
  (setq indent-tabs-mode nil)
  
  ;; Disable the bell sound on things like `C-g' when
  ;; cancelling a command.
  (setq ring-bell-function 'ignore)
  
  ;; Disable backup files.
  (setq make-backup-files nil)
  (setq create-lockfiles nil)

  ;; Change the resizing behavior to act
  ;; more like a graphical application would act.
  (setq frame-resize-pixelwise t
	frame-inhibit-implied-resize 'force)

  ;; Change the title of the frame
  ;; to display the buffer title only.
  (setq frame-title-format '("%b"))
  
  ;; Show a buffer window with command help upon
  ;; entering partially completed commands
  (which-key-mode 1)
  (which-key-setup-side-window-right-bottom)

  :custom
  ;; Enable context menu.
  (context-menu-mode t)
  
  ;; Support opening new minibuffers from
  ;; inside existing mini buffers.
  (enable-recursive-minibuffers t)
  
  ;; Hide commands in M-x which do not work in the current mode.
  (read-extended-command-predicate #'command-completion-default-include-p)
  
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))

  :config
  ;; Language Specific - Rust
  (add-hook 'rust-ts-mode-hook #'eglot-ensure)

  :bind
  (;; Use `M-o' instead of `C-x o' to facilitate faster
   ;; window switching.
   ("M-o" . other-window)
  
   ;; Make `C-g' exit out of more buffers where the default
   ;; is normally `<ESC> <ESC> <ESC>' (which is annoying).
   ("C-g" . #'timplication/just-quit-already)))

;;;;;;;;;;;;;;;;;;
;; Text Editing ;;
;;;;;;;;;;;;;;;;;;

;; This package makes `C-w` and `M-w` act on the current
;; line in case no region is selected. This makes
;; copying the current line a lot easier.
(use-package whole-line-or-region
  :config
  (whole-line-or-region-global-mode)
  (with-eval-after-load 'embark
  (cl-pushnew 'embark--mark-target
              (alist-get 'whole-line-or-region-delete-region
                         embark-around-action-hooks))))

;;;;;;;;;;;;;
;; Theming ;;
;;;;;;;;;;;;;

(use-package catppuccin-theme
    :config
    (setq catppuccin-flavor 'mocha)
    (load-theme 'catppuccin :no-confirm-loading))

(use-package nerd-icons)

(use-package nerd-icons-completion
  :after marginalia
  :config
  (add-hook 'marginalia-mode-hook
	    #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package nerd-icons-dired
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Syntax Highlighting ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Minibuffer Completion ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package vertico
  :init
  (vertico-mode))

(use-package savehist
  :init
  (savehist-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides nil)
  (completion-pcm-leading-wildcard t)
  (completion-category-defaults nil))
  
(use-package marginalia
  :init (marginalia-mode))

(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult)

;; Consult configuration based on the example configuration
;; provided in <https://github.com/minad/consult>
(use-package consult
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g r" . consult-grep-match)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  :init
  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :config
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<"))

;;;;;;;;;;;;;;;;;;;;;
;; Code Completion ;;
;;;;;;;;;;;;;;;;;;;;;

(use-package corfu
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

;; Add extensions
(use-package cape
  :bind ("C-c p" . cape-prefix-map)
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Filetype Specific - PDF ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :custom
  (pdf-view-display-size 'fit-page)
  :config
  (pdf-loader-install)
  (add-hook 'pdf-view-mode-hook #'pdf-view-roll-minor-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Filetype Specific - LaTeX ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package auctex
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
 
