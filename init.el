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
;; Modeline Customization ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Most of this is based off of `https://github.com/protesilaos/dotfiles'

(defcustom timplication/modeline-string-truncate-length 9
  "String length after which truncation
   should be done when the window is too small."
  :type 'natnum)

(defgroup timplication/modeline nil
  "Custom modeline that is stylistically close to the default."
  :group 'mode-line)

(defgroup timplication/modeline-faces nil
  "Faces for my custom modeline."
  :group 'timplication/modeline)

(defgroup timplication/icons nil
  "Get characters, icons, and symbols for things."
  :group 'convenience)

(defface timplication/modeline-indicator-red
  '((default :inherit bold)
    (((class color) (min-colors 88) (background light))
     :foreground "#880000")
    (((class color) (min-colors 88) (background dark))
     :foreground "#ff9f9f")
    (t :foreground "red"))
  "Face for modeline indicators."
  :group 'timplication/modeline-faces)

(defface timplication/icons-icon
  '((t :inherit (bold fixed-pitch)))
  "Basic attributes for an icon."
  :group 'timplication/icons)

(defface timplication/icons-gray
  '((default :inherit timplication/icons-icon)
    (((class color) (min-colors 88) (background light))
     :foreground "gray30")
    (((class color) (min-colors 88) (background dark))
     :foreground "gray70")
    (t :foreground "gray"))
  "Face for icons."
  :group 'timplication/icons)

(defun timplication/should-truncate-p (str)
  "Return non-nil value in case the `str' argument should be truncated."
  (let ((window-narrow-p
	 (and (numberp split-width-threshold)
	      (< (window-total-width) split-width-threshold))))
    (cond ((or (not (stringp str))
	       (string-empty-p str)
	       (string-blank-p str))
	   nil)
	  ((and window-narrow-p
		(> (length str) timplication/modeline-string-truncate-length)
		(not (one-window-p :no-minibuffer)))))))

(defun timplication/truncate-string (str)
  "Return the truncated `str', if appropriate. Else, return
   the unaltered `str'."
  (let ((half (floor timplication/modeline-string-truncate-length 2)))
    (if (timplication/should-truncate-p str)
	(concat (substr str 0 half) "..." (substr str (-half)))
      str)))

(defun timplication/first-char (str)
  "Return first character from `str'."
  (substring str 0 1))

(defun timplication/modeline-string-cut-end (str)
  "Return truncated STR, if appropriate, else return STR.
Cut off the end of STR by counting from its start up to
`timplication/modeline-string-truncate-length'."
  (if (timplication/should-truncate-p str)
      (concat (substring str 0 timplication/modeline-string-truncate-length) "...")
    str))

(defun timplication/buffer-name-help-echo ()
  "Return the `help-echo' value for `timplication/modeline-buffer-identifier'."
  (concat
   (propertize (buffer-name) 'face 'mode-line-buffer-id)
   "\n"
   (propertize
    (or (buffer-file-name)
	(format "No underlying file.\nDirectory is: %s" default-directory))
    'face 'font-lock-doc-face)))

(defun timplication/string-abbreviate-but-last (str nthlast)
  "Abbreviate `str', keeping `nthlast' words intact."
  (if (timplication/should-truncate-p str)
      (let* ((all-strings (split-string str "[_-]"))
             (nbutlast-strings (nbutlast (copy-sequence all-strings) nthlast))
             (last-strings (nreverse (ntake nthlast (nreverse (copy-sequence all-strings)))))
             (first-component (mapconcat #'timplication/first-char nbutlast-strings "-"))
             (last-component (mapconcat #'identity last-strings "-")))
        (if (string-empty-p first-component)
            last-component
          (concat first-component "-" last-component)))
    str))

(defun timplication/buffer-identification-face ()
  "Return the appropriate font for the buffer identification string."
  (let ((file (buffer-file-name)))
    (cond ((and (mode-line-window-selected-p)
		file
		(buffer-modified-p))
	   '(italic mode-line-buffer-id))
	  ((and file (buffer-modified-p))
	   'italic)
	  ((mode-line-window-selected-p)
	   'mode-line-buffer-id))))

(defun timplication/buffer-identification-name ()
  "Give back the name for the current buffer for usage in a mode line."
  (let ((name (timplication/truncate-string (buffer-name))))
    (if buffer-read-only
	(format " %s" name)
      name)))

(defvar timplication/icons-symbolic
  '((dired-mode "|*" timplication/icons-gray)
    (archive-mode "|@" timplication/icons-gray)
    (diff-mode ">Δ" timplication/icons-gray)
    (prog-mode ">λ" timplication/icons-gray)
    (conf-mode ">λ" timplication/icons-gray)
    (text-mode ">§" timplication/icons-gray)
    (comint-mode ">>" timplication/icons-gray)
    (git "" timplication/icons-gray)
    (eglot "∀" timplication/icons-gray)
    (t ">." timplication/icons-gray))
  "Major modes or concepts and their corresponding icons.
Each element is a cons cell of the form (THING STRING FACE), where THING
is a symbol STRING is one or more characters that represent THING, and
FACE is the face to use for it, where applicable.")

(defun timplication/icons--get (thing)
  "Return `timplication/icons-symbolic' representation of `thing'."
  (unless (symbolp thing)
    (error "the thing `%s' is not a symbol" thing))
  (when (string-suffix-p "-mode" (symbol-name thing))
    (while-let ((parent (get thing 'derived-mode-parent)))
      (setq thing parent)))
  (or (alist-get thing timplication/icons-symbolic)
      (alist-get t timplication/icons-symbolic)))

(defun timplication/modeline-major-mode-icon ()
  "Return icon for the major mode."
  (pcase-let ((`(,icon ,inherent-face) (timplication/icons--get major-mode)))
    (format "%2s" (propertize icon 'font-lock-face inherent-face 'face inherent-face))))

(defun timplication/modeline-major-mode-name ()
  "Return capitalized `major-mode' without the -mode suffix."
  (capitalize (string-replace "-mode" "" (symbol-name major-mode))))

(defun timplication/modeline-major-mode-help-echo ()
  "Return `help-echo' value for `timplication/modeline-major-mode'."
  (if-let* ((parent (get major-mode 'derived-mode-parent)))
      (format "Symbol: `%s'.  Derived from: `%s'" major-mode parent)
    (format "Symbol: `%s'." major-mode)))

(declare-function vc-git--symbolic-ref "vc-git" (file))

(defun timplication/modeline-vc-branch-name (file backend)
  "Return capitalized VC branch name for FILE with BACKEND."
  (when-let* ((rev (vc-working-revision file backend))
              (branch (or (vc-git--symbolic-ref file)
                          (substring rev 0 7))))
    (capitalize branch)))

(declare-function vc-git-working-revision "vc-git" (file))

(defvar timplication/modeline-vc-map
  (let ((map (make-sparse-keymap)))
    (define-key map [mode-line down-mouse-1] 'vc-diff)
    (define-key map [mode-line down-mouse-3] 'vc-root-diff)
    map)
  "Keymap to display on VC indicator.")

(defun timplication/modeline-vc-help-echo (file)
  "Return `help-echo' message for FILE tracked by VC."
  (format "Revision: %s\nmouse-1: `vc-diff'\nmouse-3: `vc-root-diff'"
          (vc-working-revision file)))

(defun timplication/modeline-vc-text (file branch &optional face)
  "Prepare text for Git controlled FILE, given BRANCH.
With optional FACE, use it to propertize the BRANCH."
  (format "%s %s"
	  (pcase-let ((`(,icon ,inherent-face) (timplication/icons--get 'git)))
	    (propertize icon 'font-lock-face inherent-face 'face inherent-face))
          ;; (propertize (char-to-string #xE0A0) 'face 'prot-modeline-indicator-gray)
          (propertize branch
                      'face face
                      'mouse-face 'mode-line-highlight
                      'help-echo (timplication/modeline-vc-help-echo file)
                      'local-map timplication/modeline-vc-map)))

(defun timplication/modeline-vc-details (file branch &optional face)
  "Return Git BRANCH details for FILE, truncating it if necessary.
The string is truncated if the width of the window is smaller
than `split-width-threshold'."
  (timplication/modeline-string-cut-end
   (timplication/modeline-vc-text file branch face)))

(defvar timplication/modeline-vc-faces
  '((added . vc-locally-added-state)
    (edited . vc-edited-state)
    (removed . vc-removed-state)
    (missing . vc-missing-state)
    (conflict . vc-conflict-state)
    (locked . vc-locked-state)
    (up-to-date . vc-up-to-date-state))
  "VC state faces.")

(defun timplication/modeline-vc-get-face (key)
  "Get face from KEY in `prot-modeline--vc-faces'."
  (alist-get key timplication/modeline-vc-faces 'vc-up-to-date-state))

(defun timplication/modeline-vc-face (file backend)
  "Return VC state face for FILE with BACKEND."
  (when-let* ((key (vc-state file backend)))
    (timplication/modeline-vc-get-face key)))

(defvar-local timplication/modeline-buffer-identifier
    '(:eval
      (propertize (timplication/buffer-identification-name)
		  'face (timplication/buffer-identification-face)
		  'mouse-face 'mode-line-highlight
		  'help-echo (timplication/buffer-name-help-echo)))
    "Mode line construct for identifying the current buffer.")

(defvar-local timplication/modeline-major-mode
  (list
   (propertize "%[" 'face 'timplication/modeline-indicator-red)
   '(:eval
     (concat
      (timplication/modeline-major-mode-icon)
      " "
      (propertize
       (timplication/string-abbreviate-but-last
	(timplication/modeline-major-mode-name)
	2)
       'mouse-face 'mode-line-highlight
       'help-echo (timplication/modeline-major-mode-help-echo))))
   (propertize "%]" 'face 'timplication/modeline-indicator-red))
  "Mode line construct for displaying the major mode.")

(defvar-local timplication/modeline-process
  (list '("" mode-line-process))
  "Mode line construct for the running process indicator.")

(defvar-local timplication/modeline-eglot
    `(:eval
      (when (and (featurep 'eglot) (mode-line-window-selected-p))
        '(eglot--managed-mode eglot-mode-line-format)))
  "Mode line construct displaying Eglot information.
Specific to the current window's mode line.")

(defvar-local timplication/modeline-vc-branch
    '(:eval
      (when-let* (((mode-line-window-selected-p))
                  (file (or buffer-file-name default-directory))
                  (backend (or (vc-backend file) 'Git))
                  ;; ((vc-git-registered file))
                  (branch (timplication/modeline-vc-branch-name file backend))
                  (face (timplication/modeline-vc-face file backend)))
        (timplication/modeline-vc-details file branch face)))
  "Mode line construct to return propertized VC branch.")

(defvar-local timplication/modeline-misc-info
    '(:eval
      (when (mode-line-window-selected-p)
        mode-line-misc-info))
    "Mode line construct displaying `mode-line-misc-info'.
Specific to the current window's mode line.")

(dolist (construct '(timplication/modeline-buffer-identifier
		     timplication/modeline-major-mode
		     timplication/modeline-process
                     timplication/modeline-eglot
		     timplication/modeline-vc-branch
                     timplication/modeline-misc-info))
  (put construct 'risky-local-variable t))
  

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
  
  ;; Mode Line
  (setq-default mode-line-format
		'("%e"
		  "  "
		  timplication/modeline-buffer-identifier
		  "  "
		  timplication/modeline-major-mode
		  timplication/modeline-process
                  "  "
		  timplication/modeline-vc-branch
		  "  "
                  timplication/modeline-eglot
                  "  "
                  mode-line-format-right-align
                  timplication/modeline-misc-info))




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

  ;; Mode line configuration
  (mode-line-compact nil)
  (mode-line-right-align-edge 'right-margin)

  :config
  ;; Delete "eglot" from the `mode-line-misc-info' field, as we
  ;; manually add a more simplified version of it ourselves
  ;; using `timplication/eglot'.
  (with-eval-after-load 'eglot
    (setq mode-line-misc-info
          (seq-filter (lambda (item)
                        (not (eq (car item) 'eglot--managed-mode)))
                      mode-line-misc-info)))
  
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

(use-package modus-themes
  :config
  (setq modus-themes-italic-constructs t
	modus-themes-bold-constructs nil)

  (modus-themes-load-theme 'modus-vivendi)

  (define-key global-map (kbd "<f5>") #'modus-themes-toggle)

  (defun timplication/modeline-set-faces ()
    (modus-themes-with-colors
      (custom-set-faces
       `(timplication/modeline-indicator-red ((,c :inherit bold :foreground ,red))))))
  
  (add-hook 'modus-themes-after-load-theme-hook #'timplication/modeline-set-faces))


(use-package spacious-padding
  :ensure t
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
  (setq spacious-padding-subtle-mode-line nil)

  (spacious-padding-mode 1)

  ;; Set a key binding if you need to toggle spacious padding.
  (define-key global-map (kbd "<f8>") #'spacious-padding-mode))

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
  (TeX-master "main")
  :config
  ;; enable dutch spell checking in Emacs when using `\usepackage[dutch]{babel}'
  (add-hook 'TeX-language-nl-hook (lambda () (ispell-change-dictionary "dutch")))
  ;; automatically refresh the viewer after compilation finishes.
  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer))
 
