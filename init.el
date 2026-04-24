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

  ;; Change the resizing behavior to act
  ;; more like a graphical application would act.
  (setq frame-resize-pixelwise t
	    frame-inhibit-implied-resize 'force)

  ;; Change the title of the frame
  ;; to display the buffer title only.
  (setq frame-title-format '("%b"))

  ;; Text Mode Configuration
  (add-to-list 'auto-mode-alist '("\\`\\(README\\|CHANGELOG\\|COPYING\\|LICENSE\\)\\'" . text-mode))

  (add-hook 'prog-mode-hook #'electric-indent-local-mode)
  (with-eval-after-load 'electric
    (electric-pair-mode -1)
    (electric-quote-mode -1)
    (electric-indent-mode -1))
  
  (add-hook 'text-mode-hook #'auto-fill-mode)
  (add-hook 'emacs-lisp-mode-hook (lambda () (setq-local sentence-end-double-space t)))

  (with-eval-after-load 'text-mode
    (setq sentence-end-double-space nil)
    (setq sentence-end-without-period nil)
    (setq colon-double-space nil)
    (setq use-hard-newlines nil)
    (setq adaptive-fill-mode t))

  :custom
  ;; Disable backup files.
  (setq make-backup-files nil)
  (setq backup-inhibited nil)
  (setq create-lockfiles nil)
  (auto-save-mode -1)
  
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
  :mode ("\\.\\(?:md\\|markdown\\|mkd\\|mdown\\|mkdn\\|mdwn\\)\\'" . markdown-mode)
  :config
  (setq markdown-list-indent-width 2)
  (setq markdown-fontify-code-blocks-natively t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Filetype Specific - Org ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org
  :ensure nil   ;; org-mode is built-in
  :straight nil ;; org-mode is built-in
  :demand t
  :bind (:map global-map
         ("C-c A" . org-agenda)
         ("C-c c" . org-capture)     
         :map org-mode-map
         ("C-c C-a" . nil) ;; orig. org-attach
         ;; ("C-c C-" . org-attach)
         ("C-a" . nil)
         ("C-d" . nil)
         ("C-S-d" . nil)
         ("C-'" . nil)
         ("C-," . nil)
         ("M-;" . nil)
         ("<C-return>" . nil)
         ("<C-S-return>" . nil)
         ("C-M-S-<right>" . nil)
         ("C-M-S-<left>" . nil)
         ("C-c ;" . nil)
         ("C-c C-x C-c" . nil)
         ("C-c M-l" . org-insert-last-stored-link)
         ("C-c C-M-l" . org-toggle-link-display)
         ("M-." . org-edit-special)
         :map org-src-mode-map
         ("M-," . org-edit-src-exit)
         :map narrow-map
         ("b" . org-narrow-to-block)
         ("e" . org-narrow-to-element)
         ("s" . org-narrow-to-subtree))
  :config
  (defun tim-org-open-main-agenda ()
    "Call org agenda with the main custom configuration."
    (interactive)
    (org-agenda nil "A"))

  (keymap-global-set "C-c C-a" #'tim-org-open-main-agenda)
  
           
  (setq org-directory (expand-file-name "~/Git/org/"))
  (setq org-archive-location (expand-file-name "~/Git/org/archive.org::datetree/"))
  (setq org-imenu-depth 7)

  (add-to-list 'safe-local-variable-values '(org-hide-leading-stars . t))
  (add-to-list 'safe-local-variable-values '(org-hide-macro-markers . t))

  ;; capture templates
  (setq org-capture-templates
        (let* ((without-time (concat ":PROPERTIES:\n"
                                     ":CAPTURED: %U\n"
                                     ":CUSTOM_ID: h:%(format-time-string \"%Y%m%dT%H%M%S\")\n"
                                     ":END:\n\n"
                                     "%a\n%?"))
               (with-deadline-time (concat "DEADLINE: %^T\n"
                                           ":PROPERTIES:\n"
                                           ":CAPTURED: %U\n"
                                           ":CUSTOM_ID: h:%(format-time-string \"%Y%m%dT%H%M%S\")\n"
                                           ":END:\n\n"
                                           "%a%?"))
               (with-scheduled-time (concat "SCHEDULED: %^T\n"
                                           ":PROPERTIES:\n"
                                           ":CAPTURED: %U\n"
                                           ":CUSTOM_ID: h:%(format-time-string \"%Y%m%dT%H%M%S\")\n"
                                           ":END:\n\n"
                                           "%a%?")))
          `(("m" "Meeting" entry
             (file+headline "tasks.org" "Meetings")
             ,(concat "* TODO [#A] %^{Title} :meeting:\n" with-scheduled-time)
             :empty-lines-after 1)
            ("o" "Obligation" entry
             (file+headline "tasks.org" "Obligations")
             ,(concat "* TODO [#A] %^{Title} :obligation:\n" with-deadline-time)
             :empty-lines-after 1)
            ("b" "Backlog Task" entry
             (file+headline "tasks.org" "Task Backlog")
             ,(concat "* TODO %^{Title} :backlog:\n" without-time)
             :empty-lines-after 1))))
  
  ;; calendar setup
  ;; Belgian Holidays
  (setq calendar-holidays
        '((holiday-fixed 1 1 "New Year's Day")
          (holiday-easter-etc 0 "Easter Sunday")
          (holiday-easter-etc 1 "Easter Monday") ; 1 day after Easter
          (holiday-fixed 5 1 "Labour Day")
          (holiday-easter-etc 39 "Ascension Day") ; 40 days after Easter
          (holiday-easter-etc 50 "Pentecost Monday") ; 7th Monday after Easter
          (holiday-fixed 7 21 "Belgian Independence Day")
          (holiday-fixed 8 15 "Assumption Day")
          (holiday-fixed 11 1 "All Saints' Day")
          (holiday-fixed 11 11 "Armistice Day")
          (holiday-fixed 12 25 "Christmas Day")))
  (setq calendar-mark-diary-entries-flag nil)
  (setq calendar-mark-holidays-flag t)
  (setq calendar-mode-line-format nil)
  (setq calendar-time-display-form
        '( 24-hours ":" minutes
           (when time-zone (format "(%s)" time-zone))))
  (setq calendar-week-start-day 1)
  (setq calendar-date-style 'iso)
  (setq calendar-time-zone-style 'numeric)
  ;; end calendar setup
    
  (setq org-M-RET-may-split-line '((default . nil)))
  (setq org-insert-heading-respect-content t)
  (setq org-special-ctrl-a/e nil)
  (setq org-special-ctrl-k nil)
  (setq org-cycle-separator-lines 0)
  (setq org-use-sub-superscripts '{})
  (setq org-highlight-latex-and-related nil) 
  (setq org-hide-emphasis-markers nil)
  (setq org-hide-macro-markers nil)
  (setq org-hide-leading-stars nil)
  (setq org-ellipsis " ⯆")
  (setq org-fold-catch-invisible-edits 'show)
  (setq org-yank-folded-subtrees nil)
  (setq org-read-date-prefer-future 'time)
  (setq org-return-follows-link t)
  (setq org-loop-over-headlines-in-active-region 'start-level)
  (setq org-fontify-quote-and-verse-blocks t)
  (setq org-fontify-whole-block-delimiter-line t)
  (setq org-track-ordered-property-with-tag t)
  (setq org-highest-priority ?A)
  (setq org-lowest-priority ?C)
  (setq org-default-priority ?A)
  (setq org-priority-faces nil)

  (add-hook 'org-mode-hook #'org-indent-mode)
  (setq org-indent-mode-turns-on-hiding-stars nil)
  (setq org-adapt-indentation nil)
  (setq org-indent-indentation-per-level 4)
  (setq org-startup-folded 'content)

  ;; refiling
  (setq org-refile-targets
        '((org-agenda-files . (:maxlevel . 2))
          (nil . (:maxlevel . 2))))
  (setq org-refile-use-outline-path nil)
  (setq org-refile-allow-creating-parent-nodes 'confirm)
  (setq org-refile-use-cache t)
  (setq org-reverse-note-order nil)

  ;; tagging
  (setq org-tag-alist nil)
  (setq org-auto-align-tags nil)
  (setq org-tags-column 0)

  (defface tim-org-tag-meeting
    '((default :inherit unspecified :weight regular :slant normal)
      (((class color) (min-colors 88) (background light))
       :foreground "#004476")
      (((class color) (min-colors 88) (background dark))
       :foreground "#c0d0ef")
      (t :foreground "cyan"))
    "Face for meeting Org tag.")

  (defface tim-org-tag-obligation
    '((default :inherit unspecified :weight regular :slant normal)
      (((class color) (min-colors 88) (background light))
       :foreground "#600f00")
      (((class color) (min-colors 88) (background dark))
       :foreground "#de7a66")
      (t :foreground "red"))
    "Face for obligation Org tag.")

  (defface tim-org-tag-backlog
    '((default :inherit unspecified :weight regular :slant normal)
      (((class color) (min-colors 88) (background light))
       :foreground "#603f00")
      (((class color) (min-colors 88) (background dark))
       :foreground "#deba66")
      (t :foreground "yellow"))
    "Face for backlog task Org tag.")

  (setq org-tag-faces
        '(("meeting" . tim-org-tag-meeting)
          ("obligation" . tim-org-tag-obligation)
          ("backlog" . tim-org-tag-backlog)
          ("lecture" . tim-org-tag-meeting)))

  (defface tim-org-todo-alternative
    '((t :inherit (italic org-todo)))
    "Face for alternative TODO-type Org keywords.")

  (defface tim-org-done-alternative
    '((t :inherit (italic org-done)))
    "Face for alternative DONE-type Org keywords.")

  (setq org-todo-keyword-faces
        '(("MAYBE" . tim-org-todo-alternative)
          ("CANCELLED" . tim-org-done-alternative)))

  (setq org-use-fast-todo-selection 'expert)
  (setq org-fontify-done-headline nil)
  (setq org-fontify-todo-headline nil)
  (setq org-fontify-whole-heading-line nil)
  (setq org-enforce-todo-dependencies t)
  (setq org-enforce-todo-checkbox-dependencies t)

  ;; logging
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-log-note-clock-out nil)
  (setq org-log-redeadline 'time)
  (setq org-log-reschedule 'time)

  ;; links
  (setq org-return-follows-link t)
  (setq org-link-context-for-files t)
  (setq org-link-keep-stored-after-insertion nil)
  (setq org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "MAYBE(m)" "|" "CANCELLED(C@)" "DONE(d!)")))

  ;; agenda

  (defun tim-org-agenda-include-priority-no-timestamp ()
    "Return nil if heading has a priority but no timestamp.
Otherwise, return the buffer position from where the search should
continue, per `org-agenda-skip-function'."
    (let ((point (point)))
      (if (and (eq (nth 3 (org-heading-components)) ?A)
               (not (org-get-deadline-time point))
               (not (org-get-scheduled-time point)))
          nil
        (line-beginning-position 2))))

  (defvar tim-org-custom-daily-agenda
    `((tags-todo "*"
                 ((org-agenda-overriding-header "\nAnytime\n")
                  (org-agenda-skip-function #'tim-org-agenda-include-priority-no-timestamp)
                  (org-agenda-block-separator nil)))
      (agenda "" ((org-agenda-overriding-header "\nToday\n")
                  (org-agenda-span 1)
                  (org-deadline-warning-days 0)
                  (org-agenda-block-separator nil)
                  (org-scheduled-past-days 0)
                  (org-agenda-skip-function '(org-agenda-skip-entry-if 'regexp "ROUTINE"))
                  ;; We don't need the `org-agenda-date-today'
                  ;; highlight because that only has a practical
                  ;; utility in multi-day views.
                  (org-agenda-day-face-function (lambda (date) 'org-agenda-date))))
                  ;;(org-agenda-format-date "")))
      (agenda "" ((org-agenda-overriding-header "\nUpcoming (+3d)\n")
                  (org-agenda-start-on-weekday nil)
                  (org-agenda-start-day nil)
                  (org-agenda-start-day "+1d")
                  (org-agenda-span 3)
                  (org-deadline-warning-days 0)
                  (org-agenda-block-separator nil)
                  (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))))
      (agenda "" ((org-agenda-overriding-header "\nUpcoming Deadlines (+14d)\n")
                  (org-agenda-time-grid nil)
                  (org-agenda-start-on-weekday nil)
                  ;; We don't want to replicate the previous section's
                  ;; three days, so we start counting from the day after.
                  (org-agenda-start-day "+4d")
                  (org-agenda-span 14)
                  (org-agenda-show-all-dates nil)
                  (org-deadline-warning-days 0)
                  (org-agenda-block-separator nil)
                  (org-agenda-entry-types '(:deadline))
                  (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))))
      (agenda "" ((org-agenda-overriding-header "Overdue\n")
                  (org-agenda-time-grid nil)
                  (org-agenda-start-on-weekday nil)
                  (org-agenda-span 1)
                  (org-agenda-show-all-dates nil)
                  (org-scheduled-past-days 365)
                  ;; Excludes today's scheduled items
                  (org-scheduled-delay-days 1)
                  (org-agenda-block-separator nil)
                  (org-agenda-entry-types '(:scheduled))
                  (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                  (org-agenda-skip-function '(org-agenda-skip-entry-if 'regexp "ROUTINE"))
                  (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                  (org-agenda-format-date "")))))

  (setq org-agenda-custom-commands
        `(("A" "Daily agenda and top priority tasks"
           ,tim-org-custom-daily-agenda
           ((org-agenda-fontify-priorities nil)
            (org-agenda-dim-blocked-tasks nil)))))

                  
  (setq org-default-notes-file (make-temp-file "emacs-org-notes-")) ; send it to oblivion
  (setq org-agenda-files (list org-directory))
  (setq org-agenda-span 'week)
  (setq org-agenda-start-on-weekday 1)  ; Monday
  (setq org-agenda-confirm-kill t)
  (setq org-agenda-show-all-dates t)
  (setq org-agenda-show-outline-path nil)
  (setq org-agenda-window-setup 'current-window)
  (setq org-agenda-skip-comment-trees t)
  (setq org-agenda-menu-show-matcher t)
  (setq org-agenda-menu-two-columns nil)
  (setq org-agenda-sticky nil)
  (setq org-agenda-custom-commands-contexts nil)
  (setq org-agenda-max-entries nil)
  (setq org-agenda-max-todos nil)
  (setq org-agenda-max-tags nil)
  (setq org-agenda-max-effort nil)

  ;; agenda view
  (setq org-agenda-prefix-format "%c	 %t %s")

  (setq org-agenda-breadcrumbs-separator "->")
  (setq org-agenda-todo-keyword-format "%-1s")
  (setq org-agenda-fontify-priorities 'cookies)
  (setq org-agenda-category-icon-alist nil)
  (setq org-agenda-remove-times-when-in-prefix nil)
  (setq org-agenda-remove-timeranges-from-blocks nil)
  (setq org-agenda-compact-blocks nil)
  (setq org-agenda-block-separator ?—)

  (setq org-agenda-start-with-follow-mode nil)
  (setq org-agenda-follow-indirect t)
  (setq org-agenda-dim-blocked-tasks t)
  (setq org-agenda-todo-list-sublevels t)
  (setq org-agenda-persistent-filter nil)
  (setq org-agenda-restriction-lock-highlight-subtree t)

  (setq org-agenda-include-deadlines t)
  (setq org-deadline-warning-days 0)
  (setq org-agenda-skip-scheduled-if-done nil)
  (setq org-agenda-skip-scheduled-if-deadline-is-shown t)
  (setq org-agenda-skip-timestamp-if-deadline-is-shown t)
  (setq org-agenda-skip-deadline-if-done nil)
  (setq org-agenda-skip-deadline-prewarning-if-scheduled 1)
  (setq org-agenda-skip-scheduled-delay-if-deadline nil)
  (setq org-agenda-skip-additional-timestamps-same-entry nil)
  (setq org-agenda-skip-timestamp-if-done nil)
  (setq org-agenda-search-headline-for-time nil)
  (setq org-scheduled-past-days 365)
  (setq org-deadline-past-days 365)
  (setq org-agenda-move-date-from-past-immediately-to-today t)
  (setq org-agenda-show-future-repeats t)
  (setq org-agenda-prefer-last-repeat nil)
  (setq org-agenda-timerange-leaders
        '("" "(%d/%d): "))
  (setq org-agenda-scheduled-leaders
        '("Scheduled: " "Sched.%2dx: "))
  (setq org-agenda-inactive-leader "[")
  (setq org-agenda-deadline-leaders
        '("Deadline:  " "In %3d d.: " "%2d d. ago: "))
  
  ;; Time grid
  (setq org-agenda-time-leading-zero t)
  (setq org-agenda-timegrid-use-ampm nil)
  (setq org-agenda-use-time-grid t)
  (setq org-agenda-show-current-time-in-grid t)
  (setq org-agenda-current-time-string (concat "Now " (make-string 70 ?.)))
  (setq org-agenda-time-grid
        '((daily today require-timed)
          ( 0500 0600 0700 0800 0900 1000
            1100 1200 1300 1400 1500 1600
            1700 1800 1900 2000 2100 2200)
          "" ""))
  (setq org-agenda-default-appointment-duration nil)

  (setq org-agenda-todo-ignore-with-date t)
  (setq org-agenda-todo-ignore-timestamp t)
  (setq org-agenda-todo-ignore-scheduled t)
  (setq org-agenda-todo-ignore-deadlines t)
  (setq org-agenda-todo-ignore-time-comparison-use-seconds t)
  (setq org-agenda-tags-todo-honor-ignore-options nil)

  (setq org-agenda-show-inherited-tags t)
  (setq org-agenda-use-tag-inheritance
        '(todo search agenda))
  (setq org-agenda-hide-tags-regexp nil)
  (setq org-agenda-remove-tags nil)
  (setq org-agenda-tags-column 1)
  
  (defun tim-pulsar-show ()
    (require 'pulsar)
    (pulsar-recenter-center)
    (pulsar-reveal-entry))
  
  (add-hook 'org-agenda-after-show-hook #'tim-pulsar-show)
  (add-hook 'org-follow-link-hook #'tim-pulsar-show))
  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Filetype Specific - PDF ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package pdf-tools
  :config
  (pdf-loader-install)
  (add-hook 'pdf-view-mode-hook (lambda ()
				  (pdf-view-roll-minor-mode)
				  (pdf-view-themed-minor-mode)))
  
  (defun tim/pdf-view-refresh-themed-buffers (&optional theme)
    "Refreshes the PDF View themes if a pdf-view-mode buffer is active."
    (interactive)
    (require 'pdf-tools)
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (eq major-mode 'pdf-view-mode)
          (pdf-view-refresh-themed-buffer t)))))

  (add-hook 'enable-theme-functions 'tim/pdf-view-refresh-themed-buffers))

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
  (add-hook 'LaTeX-mode-hook (lambda ()
                               (keymap-unset LaTeX-mode-map "C-c C-a")))
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

;;;;;;;;;;;;;;;;
;; Completion ;;
;;;;;;;;;;;;;;;;

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

;; I currently only use this for `embark-prefix-help-command'
;; That is, if you do `<prefix> C-h' a window with a
;; vertico-muliform will pop up with the keybinds under that prefix.
;; I intend to use this for more features when I have a better understanding
;; of the kind of workflow I want to create with this package.
(use-package embark
  :after (vertico)
  :demand t
  :bind (("C-." . embark-act)
         ("M-." . embark-dwim))
  :config
  (setq embark-indicators
      '(embark-minimal-indicator  ; default is embark-mixed-indicator
        embark-highlight-indicator
        embark-isearch-highlight-indicator))
  
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package consult
  :bind (;; Bindings in the `goto-map'
         ("M-g M-g" . consult-goto-line) ;; orig. goto-line
         ("M-g M-e" . consult-compile-error)
         ("M-g M-f" . consult-flymake)
         ;; Bindings in the `search-map' and `isearch-mode-map'
         ("M-s M-b" . consult-buffer)
         ("M-s M-f" . consult-find)
         ("M-s M-g" . consult-ripgrep)
         ("M-s M-i" . consult-imenu)
         ("M-s M-y" . consult-yank-pop)
         ("M-s M-s" . consult-outline)
         :map isearch-mode-map
         ("M-s M-l" . consult-line))
  :init
  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :config
  (setq consult-line-numbers-widen t)
  (setq consult-async-min-input 3)
  (setq consult-async-input-debounce 0.5)
  (setq consult-async-input-throttle 0.8)
  (setq consult-narrow-key nil)
  (setq consult-find-args
        (concat "find . -not ( "
                "-path *./.git* -prune "
                "-or -path */.cache* -prune )"))
  (setq consult-preview-key 'any)
  (setq consult-project-function nil)

  ;; Integration with the Pulsar package.
  (add-hook 'consult-after-jump-hook (lambda ()
                                       (require 'pulsar)
				                       (pulsar-recenter-top)
				                       (pulsar-reveal-entry))))

(use-package embark-consult
  :after (embark consult))

(use-package corfu
  :after (savehist)
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
        modus-themes-italic-constructs t
        modus-themes-headings
        '((0 . (variable-pitch medium 1.4))
          (1 . (variable-pitch medium 1.3))
          (2 . (variable-pitch semibold 1.2))
          (3 . (variable-pitch semibold 1.1))
          (4 . (variable-pitch semibold 1.1))
          (5 . (variable-pitch semibold 1.1))
          (6 . (variable-pitch semibold 1.1))
          (7 . (variable-pitch semibold 1.1))
          (agenda-date . (semibold 1.2))
          (agenda-structure . (variable-pitch medium 1.4))
          (t . (variable-pitch semibold 1.1))))

  (modus-themes-with-colors
    (custom-set-faces
     `(tim-org-tag-backlog ((,c :inherit italic :foreground ,green)))
     `(tim-org-tag-meeting ((,c :inherit italic :foreground ,red)))
     `(tim-org-tag-obligation ((,c :inherit italic :foreground ,cyan))))))

;;;; Theme Buffet -- Switch themes randomly based on the time of day.

(use-package theme-buffet
  :demand t
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
  (theme-buffet-timer-hours 2)
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
  (setopt lin-face 'lin-slate)
  (lin-global-mode 1))

;;;; Pulsar -- animations for selections, marking, etc.

(use-package pulsar
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
    (require 'battery)
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
           :inherit medium
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

