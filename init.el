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

(defun timplication/portable-device-p ()
  "Return non-nil if emacs is running on a portable device."
  (let ((chassis (string-trim (shell-command-to-string "hostnamectl chassis"))))
    (or (eq system-type 'darwin)
        (string= chassis "laptop")
	(string= chassis "convertible")
	(string= chassis "tablet")
	(string= chassis "handset"))))

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

  ;; Tab configuration
  (setq tab-bar-new-button-show nil)
  (setq tab-bar-close-button-show nil)
  (setq tab-bar-show 1)

  ;; Something that helps with embark.el
  (setq y-or-n-p-use-read-key t)

  ;; Mouse Settings
  (mouse-wheel-mode 1)
  (setq mouse-autoselect-window t)
  (setq focus-follows-mouse t)

  ;; Force eldoc to only use a single line, I find it
  ;; a bit distracting to see the modeline jumping up and
  ;; down every time you hover over some piece of code.
  (setq eldoc-echo-area-use-multiline-p nil)

  ;; In Emacs 27+, use Control + mouse wheel to scale text.
  (setq mouse-wheel-scroll-amount
        '(1
          ((shift) . 5)
          ((meta) . 0.5)
          ((control) . text-scale))
        mouse-drag-copy-region nil
        make-pointer-invisible t
        mouse-wheel-progressive-speed t
        mouse-wheel-follow-mouse t)

  ;; Scrolling behaviour
  (setq scroll-preserve-screen-position t
        scroll-conservatively 1 ; affects `scroll-step'
        scroll-margin 0
        next-screen-context-lines 0)

  ;; Unique buffer names
  (setq uniquify-buffer-name-style 'forward)
  (setq uniquify-strip-common-suffix t)
  (setq uniquify-after-kill-buffer-p t)

  ;; Highlight Line
  (setq hl-line-sticky-flag nil)
  (setq hl-line-overlay-priority -50)

  ;; Negative space highlight
  (setq whitespace-style
        '(face
          tabs
          spaces
          newline
          tab-mark
          space-mark
          newline-mark
          trailing
          missing-newline-at-eof
          space-after-tab::tab
          space-after-tab::space
          space-before-tab::tab
          space-before-tab::space))

  ;; Split preferences
  (setq split-window-preferred-direction 'horizontal)
  (setq window-combination-resize t)
  (setq even-window-sizes 'height-only)
  (setq window-sides-vertical nil)
  (setq switch-to-buffer-in-dedicated-window 'pop)
  (setq split-height-threshold 85)
  (setq split-width-threshold 125)
  (setq window-min-height 3)
  (setq window-min-width 30)
  
  ;; Stop the default splash screen from showing up. 
  (setq inhibit-startup-screen t)

  ;; Indent with spaces instead of tabs
  (setq-default indent-tabs-mode nil
		tab-width 4
		fill-column 100)

  ;; set fill column width
  (setq-default fill-column 100)
  
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

  ;; Text Mode Configuration
  (add-to-list 'auto-mode-alist '("\\`\\(README\\|CHANGELOG\\|COPYING\\|LICENSE\\)\\'" . text-mode))

  (add-hook 'text-mode-hook #'auto-fill-mode)
  (add-hook 'emacs-lisp-mode-hook (lambda () (setq-local sentence-end-double-space t)))

  (with-eval-after-load 'text-mode
    (setq sentence-end-double-space nil)
    (setq sentence-end-without-period nil)
    (setq colon-double-space nil)
    (setq use-hard-newlines nil)
    (setq adaptive-fill-mode t))


  :custom
  ;; Enable context menu.
  (context-menu-mode t)

  (enable-recursive-minibuffers t)
  
  ;; Hide commands in M-x which do not work in the current mode.
  (read-extended-command-predicate #'command-completion-default-include-p)
  
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))

  ;; Mode line configuration
  (mode-line-compact nil)
  (mode-line-right-align-edge 'right-margin)

  :config
  ;; Support opening new minibuffers from
  ;; inside existing mini buffers.
  (setq enable-recursive-minibuffers t)

  ;; Quality of life stuff
  (setq help-window-select t)
  (setq help-window-keep-selected t)
  (setq scroll-error-top-bottom t)

  ;; Dired Configuration
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'always)
  (setq delete-by-moving-to-trash t)
  (setq dired-dwim-target t)
  (setq dired-auto-revert-buffer #'dired-directory-changed-p) ; also see `dired-do-revert-buffer'
  (setq dired-make-directory-clickable t) ; Emacs 29.1
  (setq dired-free-space nil) ; Emacs 29.1
  (add-hook 'dired-mode-hook (lambda ()
                               (dired-hide-details-mode)
                               (hl-line-mode)))

  ;; Tooltips
  (tooltip-mode 1)
  (setq tooltip-delay 0.5
        tooltip-short-delay 0.5
        x-gtk-use-system-tooltips t
        tooltip-frame-parameters
        '((name . "tooltip")
          (internal-border-width . 10)
          (border-width . 0)
          (no-special-glyphs . t)))

  ;; Language Specific - Rust
  (add-hook 'rust-ts-mode-hook #'eglot-ensure)

  :bind
  (;; Use `M-o' instead of `C-x o' to facilitate faster
   ;; window switching.
   ("M-o" . other-window)
   
   ;; Make `C-g' exit out of more buffers where the default
   ;; is normally `<ESC> <ESC> <ESC>' (which is annoying).
   ("C-g" . #'timplication/just-quit-already)))

;;;;;;;;;;;;;;;;;;;;;;
;; PATH Integration ;;
;;;;;;;;;;;;;;;;;;;;;;

(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns pgtk x))
    (exec-path-from-shell-initialize))
  (when (daemonp)
    (exec-path-from-shell-initialize)))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Syntax Highlighting ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (setq treesit-auto-langs
        '(awk bash bibtex blueprint c c-sharp clojure cmake cobol
              commonlisp cpp css dart dockerfile elixir gitcommit
              glsl go gomod gowork haskell heex html hyprlang
              janet-simple java javascript json julia kotlin
              lua magik make nix nu org perl php proto python r
              ruby rust scala sql toml tsx typescript typespec
              typst vue wast wat zig wgsl yaml))
  (global-treesit-auto-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Filetype Specific - Markdown ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package markdown-mode
  :after (embark)
  :mode ("\\.\\(?:md\\|markdown\\|mkd\\|mdown\\|mkdn\\|mdwn\\)\\'" . markdown-mode)
  :config
  (setq markdown-list-indent-width 2)
 
  (setq markdown-fontify-code-blocks-natively t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Filetype Specific - PDF ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package pdf-tools
  :config
  (pdf-loader-install)
  (add-hook 'pdf-view-mode-hook (lambda ()
				  (pdf-view-roll-minor-mode)
				  (pdf-view-themed-minor-mode))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Filetype Specific - LaTeX ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package auctex
  :custom
  ;; Parse the file when saving it
  (TeX-auto-save t)
  ;; Parse the file when first loading it.
  (TeX-parse-self t)
  ;; Always convert tabs to spaces automatically.
  (TeX-auto-untabify t)
  ;; Set the default viewer to use the `pdf-tools` viewer inside Emacs.
  (TeX-view-program-selection '((output-pdf "PDF Tools")))
  (TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view)))
  ;; enable support for forward an inverse search with SyncTeX
  (TeX-source-correlate-mode t)
  (TeX-source-correlate-method 'synctex)
  ;; always start the viewer process automatically, do not ask
  (TeX-source-correlate-start-server t)
  ;; Always use the XeTeX-engine.
  (TeX-engine 'xetex)
  ;; The built PDF files always get dumped into a "build/" folder.
  (TeX-output-dir "build")
  ;; The main entry point file is always called "main" in my projects.
  (TeX-master nil)
  :config
  ;; enable dutch spell checking in Emacs when using `\usepackage[dutch]{babel}'
  ;;(add-hook 'TeX-language-nl-hook (lambda () (ispell-change-dictionary "dutch")))
  ;; automatically refresh the viewer after compilation finishes.
  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer))
 
;;;;;;;;;;;;;;;;;;;;;;;;
;; Terminal Emulation ;;
;;;;;;;;;;;;;;;;;;;;;;;;

(use-package vterm
  :config
  (setq vterm-clear-scrollback-when-clearing t)
  (setq vterm-kill-buffer-on-exit t)
  (setq vterm-max-scrollback 50000)
  :bind
  (("<f1>" . vterm-other-window)
   ("C-<f1>" . vterm)))


;;;;;;;;;;;;;;;;;;;;;
;; Version Control ;;
;;;;;;;;;;;;;;;;;;;;;

(use-package magit)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Minibuffer Completion ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package vertico
  :init
  (vertico-mode)
  (vertico-multiform-mode)
  (setq vertico-multiform-categories
        '((embark-keybinding grid))))

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
  :after (markdown-mode)
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("M-." . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings))

  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  :config
  (setq embark-indicators
        '(embark-minimal-indicator  ; default is embark-mixed-indicator
          embark-highlight-indicator
          embark-isearch-highlight-indicator))

  ;;;; embark-markdown

  (defun embark-markdown-next-list-item (args)
    (markdown-next-list-item
     (+ markdown-list-indent-width (current-indentation))))

  (defun embark-markdown-prev-list-item (args)
    (markdown-prev-list-item
     (+ markdown-list-indent-width (current-indentation))))

  (defun embark-markdown-down-list-item (args)
    (markdown-next-list-item
     (+ (* markdown-list-indent-width 2)
        (current-indentation))))

  (defun embark-markdown-up-list-item (args)
    (markdown-prev-list-item
     (- (current-indentation)
        markdown-list-ident-width)))

  (defun embark-markdown-demote-list-item (args)
    (markdown-demote-list-item))

  (defun embark-markdown-promote-list-item (args)
    (markdown-promote-list-item))

  (defun embark-markdown-move-list-item-up (args)
    (markdown-move-list-item-up))

  (defun embark-markdown-move-list-item-down (args)
    (markdown-move-list-item-down))
  
  (defvar-keymap embark-markdown-plain-list-map
    :doc "Embark action map for plain lists in markdown files."
    :parent embark-general-map
    "n" #'embark-markdown-next-list-item
    "p" #'embark-markdown-prev-list-item
    "d" #'embark-markdown-down-list-item
    "u" #'embark-markdown-up-list-item
    "C-d" #'embark-markdown-demote-list-item
    "C-p" #'embark-markdown-promote-list-item
    "C-t" #'embark-markdown-move-list-item-down
    "C-u C-t" #'embark-markdown-move-list-item-up)

  (dolist (cmd '(embark-markdown-next-list-item
                 embark-markdown-prev-list-item
                 embark-markdown-down-list-item
                 embark-markdown-up-list-item))
    (add-to-list 'embark-repeat-actions cmd))

  ;; embark-target-finders: requires (TYPE TARGET START . END) format
  ;; TYPE: symbol looked up in `embark-keymap-alist' to determine keybinds
  ;; TARGET: string used for highlighting
  ;; START: buffer position marking start of TARGET
  ;; END: buffer position marking end of TARGET.
  (defun embark-markdown-plain-list-item ()
    "Target a markdown plain list item."
    (let ((list-item (markdown-cur-list-item-bounds)))
      (when list-item
        (pcase-let ((`(,begin ,end ,indent ,nonlist-indent ,marker ,checkbox ,match)
                     list-item))
          `(md-plain-list-item ,(buffer-substring-no-properties (+ begin indent) end)
                               ,begin . ,end)))))   

  (add-to-list 'embark-target-finders 'embark-markdown-plain-list-item)

  (add-to-list 'embark-keymap-alist '(md-plain-list-item . embark-markdown-plain-list-map))

  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :after (embark consult))

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
         ("M-r" . consult-history))                 ;; orig. previous-matching-history-element


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

  (add-hook 'consult-after-jump-hook (lambda ()
				       (pulsar-recenter-top)
				       (pulsar-reveal-entry)))

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

;;;; Modus Themes -- Base theme functionality used by ef-themes, also provides the modus operandi
;;;; and modus vivendi themes.

(use-package modus-themes
  :demand t)

;;;; EF Themes -- More colorful themes that modify the modus themes.

(use-package ef-themes
  :demand t
  :init
  (ef-themes-take-over-modus-themes-mode 1)
  :config
  (setq modus-themes-variable-pitch-ui t
        modus-themes-mixed-fonts t
        modus-themes-bold-constructs t
        modus-themes-italic-constructs t))

;;;; Theme Buffet -- Switch themes randomly based on the time of day.

(use-package theme-buffet
  :after (modus-themes ef-themes)
  :functions
  calendar-current-time-zone
  theme-buffet-timer-hours
  :bind
  (("<f5>" . theme-buffet-a-la-carte)
   ("C-<f5>" . theme-buffet-order-other-period))
  :init
  (setq theme-buffet-menu 'end-user)
  (add-hook 'emacs-startup-hook #'theme-buffet-a-la-carte)
  :config
  (setq theme-buffet-end-user
        '(:night     ; Active between 00:00 and 04:00.
          (ef-trio-dark ef-winter ef-cherie)
          :twilight  ; Active between 04:00 and 08:00.
	  (ef-dream ef-melissa-dark ef-owl)
          :morning   ; Active between 08:00 and 12:00.
          (ef-trio-light ef-kassio ef-day)   
          :day       ; Active between 12:00 and 16:00.
          (ef-trio-light ef-kassio ef-day)            
          :afternoon ; Active between 16:00 and 20:00.
          (ef-summer ef-orange ef-melissa-light)  
          :evening   ; Active between 20:00 and 00:00.
          (ef-trio-dark ef-winter ef-cherie)))

  (theme-buffet-end-user)
  (theme-buffet-timer-hours 1)
  (theme-buffet-a-la-carte))

;;;; Spacious Padding -- Enable extra spacing around modelines and windows.

(use-package spacious-padding
  :demand t
  :bind
  (("<f8>" . spacious-padding-mode))
  :config
  ;; These are the default values, but I keep them here for visibility.
  ;; Also check `spacious-padding-subtle-frame-lines'.
  (setq spacious-padding-widths
	'(:internal-border-width 15
          :header-line-width 4
          :mode-line-width 6
          :tab-width 4
          :right-divider-width 15
          :scroll-bar-width 12
	  :left-fringe-width 20
	  :right-fringe-width 20))
  
  (setq spacious-padding-subtle-frame-lines
        '( :mode-line-active spacious-padding-line-active
           :mode-line-inactive spacious-padding-line-inactive
           :header-line-active spacious-padding-line-active
           :header-line-inactive spacious-padding-line-inactive))

  (spacious-padding-mode 1))

;;;; Lin -- `hl-line-mode' styling.

(use-package lin
  :config
  (setopt lin-face 'lin-magenta)
  (lin-global-mode 1))

;;;; Pulsar -- animations for selections, marking, etc.

(use-package pulsar
  :bind
  (:map global-map
    ("C-x l" . pulsar-pulse-line)                  ; overrides `count-lines-page'
    ("C-x L" . pulsar-highlight-permanently-dwim)) ; or use `pulsar-highlight-temporarily-dwim'
  :config
  (setq pulsar-delay 0.055)
  (setq pulsar-iterations 5)
  (setq pulsar-face 'pulsar-green)
  (setq pulsar-region-face 'pulsar-yellow)
  (setq pulsar-highlight-face 'pulsar-magenta)

  (defun timplication/pulsar-mark-error ()
    (pulsar-pulse-line-red)
    (pulsar-recenter-top)
    (pulsar-reveal-entry))

  (add-hook 'next-error-hook #'timplication/pulsar-mark-error)
  (add-hook 'minibuffer-setup-hook #'timplication/pulsar-mark-error)
  (pulsar-global-mode 1))

;;;; Nerd Icons -- Embed the Nerd Font icons (e.g., for filetypes) in various aspects of the editor.

(use-package nerd-icons
  :config
  ;; Set up a battery indicator on laptops.
  (when (timplication/portable-device-p)
    (setq battery-mode-line-format
          (cond
           ((eq battery-status-function #'battery-linux-proc-acpi)
	    (format "%s %s" (nerd-icons-mdicon "nf-md-battery") "%b%p%%, %d°C "))
	   (battery-status-function
	    (format "%s %s" (nerd-icons-mdicon "nf-md-battery") "%b%p%% "))))

    (display-battery-mode 1)))

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

;;;; Tim Modeline -- Custom minimalist modeline.

(use-package tim-modeline
  :after (nerd-icons modus-themes ef-themes)
  :straight (tim-modeline :local-repo "~/.emacs.d/local-packages/tim-modeline" :type nil)
  :config
  (tim-modeline-setup))

;;;; Fontaine -- Font configuration presets.

(use-package fontaine
  :after (modus-themes ef-themes)
  :demand t
  :bind
  (("C-c f" . fontaine-set-preset)
   ("C-c F" . fontaine-toggle-preset)
   ;; Resize keys with global effect
   ;; Emacs 29 introduces commands that resize the font across all
   ;; buffers (including the minibuffer), which is what I want, as
   ;; opposed to doing it only in the current buffer.  The keys are the
   ;; same as the defaults.
   ("C-x C-=" . global-text-scale-adjust)
   ("C-x C-+" . global-text-scale-adjust)
   ("C-x C-0" . global-text-scale-adjust)
   :map ctl-x-x-map
   ("v" . variable-pitch-mode))
  :config
  (setq-default text-scale-remap-header-line t) ; Emacs 28

  (setq fontaine-presets
        '((small
           :default-height 120)
          (regular) ; like this it uses all the fallback values and is named `regular'
          (medium
           :default-family "Iosevka Curly Slab"
           :default-height 160
           :fixed-pitch-family "Iosevka Curly Slab"
           :variable-pitch-family "Iosevka Etoile")
          (large
           :default-height 180)
          (presentation
           :default-height 200)
          (jumbo
           :inherit medium
           :default-height 260)
          (t
           :default-family "Iosevka Curly"
           :default-weight semibold
           :default-slant normal
           :default-width normal
           :default-height 140

           :fixed-pitch-family "Iosevka Curly"
           :fixed-pitch-weight nil
           :fixed-pitch-slant nil
           :fixed-pitch-width nil
           :fixed-pitch-height 1.0

           :fixed-pitch-serif-family nil
           :fixed-pitch-serif-weight nil
           :fixed-pitch-serif-slant nil
           :fixed-pitch-serif-width nil
           :fixed-pitch-serif-height 1.0

           :variable-pitch-family "Iosevka Etoile"
           :variable-pitch-weight nil
           :variable-pitch-slant nil
           :variable-pitch-width nil
           :variable-pitch-height 1.0

           :mode-line-active-family nil
           :mode-line-active-weight nil
           :mode-line-active-slant nil
           :mode-line-active-width nil
           :mode-line-active-height 1.0

           :mode-line-inactive-family nil
           :mode-line-inactive-weight nil
           :mode-line-inactive-slant nil
           :mode-line-inactive-width nil
           :mode-line-inactive-height 1.0

           :header-line-family nil
           :header-line-weight nil
           :header-line-slant nil
           :header-line-width nil
           :header-line-height 1.0

           :line-number-family nil
           :line-number-weight nil
           :line-number-slant nil
           :line-number-width nil
           :line-number-height 1.0

           :tab-bar-family nil
           :tab-bar-weight nil
           :tab-bar-slant nil
           :tab-bar-width nil
           :tab-bar-height 1.0

           :tab-line-family nil
           :tab-line-weight nil
           :tab-line-slant nil
           :tab-line-width nil
           :tab-line-height 1.0

           :bold-family nil
           :bold-slant nil
           :bold-weight extrabold
           :bold-width nil
           :bold-height 1.0

           :italic-family nil
           :italic-weight nil
           :italic-slant italic
           :italic-width nil
           :italic-height 1.0

           :line-spacing nil)))

  (with-eval-after-load 'pulsar
    (add-hook 'fontaine-set-preset-hook #'pulsar-pulse-line))
  
  (fontaine-mode 1)
  (fontaine-set-preset (or (fontaine-restore-latest-preset) 'regular))

  (defun timplication/enable-variable-pitch ()
    (unless (derived-mode-p 'mhtml-mode 'nxml-mode 'yaml-mode)
      (when (bound-and-true-p modus-themes-mixed-fonts)
        (variable-pitch-mode 1))))

  (add-hook 'modus-themes-after-load-theme-hook (lambda () (fontaine-mode 1)))
  (add-hook 'text-mode-hook #'timplication/enable-variable-pitch))

;;;; Cursory --- Make changes to the appearance of the point.

(use-package cursory
  :demand t
  :if (display-graphic-p)
  :config
  (setq cursory-presets
        '((box
           :blink-cursor-interval 1.2)
          (box-no-blink
           :inherit box
           :blink-cursor-mode -1)
          (bar
           :cursor-type (bar . 2)
           :cursor-color error ; will typically be red
           :blink-cursor-interval 0.8)
          (bar-no-other-window
           :inherit bar
           :cursor-in-non-selected-windows nil)
          (bar-no-blink
           :inherit bar
           :blink-cursor-mode -1)
          (underscore
           :cursor-color warning ; will typically be yellow
           :cursor-type (hbar . 3)

           :blink-cursor-blinks 50)
          (underscore-no-other-window
           :inherit underscore
           :cursor-in-non-selected-windows nil)
          (underscore-thick
           :inherit underscore
           :cursor-type (hbar . 8)
           :cursor-in-non-selected-windows (hbar . 3))
          (t ; the default values
           :cursor-color unspecified ; use the theme's original
           :cursor-type box
           :cursor-in-non-selected-windows hollow
           :blink-cursor-mode 1
           :blink-cursor-blinks 10
           :blink-cursor-interval 0.2
           :blink-cursor-delay 0.2)))
  
    ;; Persist configurations between Emacs sessions.  Also apply the
    ;; :cursor-color again when swithcing to another theme.
  (cursory-mode 1))

