;; tim-modeline.el --- custom minimalist modeline  -*- lexical-binding: t; -*-

;; Name: tim-modeline
;; Author: Tim Baccaert <tim@baccaert.com>
;; Created: 14 Apr 2026
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.0") (nerd-icons "0.1.0") (modus-themes "5.0.0") (ef-themes "2.0.0"))

;;; Commentary:

;; This file defines a custom modeline that is quite close to the functionality that the built-in
;; modeline provides.  I have based it largely off of Protesilaos' modeline as this was quite close
;; to the minimalist design I had in mind. For reference and attribution, the source for that
;; configuration is located at the following URL: <https://github.com/protesilaos/dotfiles>.

;;; Code:

(require 'nerd-icons)
(require 'modus-themes)
(require 'ef-themes)

;;;; Custom Variables

(defcustom tim-modeline-string-truncate-length 20
  "String length after which truncation
   should be done when the window is too small."
  :type 'natnum)

;;;; Custom Faces

(defgroup tim-modeline nil
  "Custom modeline that is stylistically close to the default."
  :group 'mode-line)

(defgroup tim-modeline-faces nil
  "Faces for my custom modeline."
  :group 'tim-modeline)

(defgroup tim-modeline-icons nil
  "Get characters, icons, and symbols for things."
  :group 'convenience)

(defface tim-modeline-indicator-button nil
  "Generic face used for indicators that have a background.
Modify this face to, for example, add a :box attribute to all
relevant indicators.")

(defface tim-modeline-indicator-red
  '((default :inherit bold)
    (((class color) (min-colors 88) (background light))
     :foreground "#880000")
    (((class color) (min-colors 88) (background dark))
     :foreground "#ff9f9f")
    (t :foreground "red"))
  "Face for modeline indicators."
  :group 'tim-modeline-faces)

(defface tim-modeline-indicator-red-bg
  '((default :inherit (bold tim-modeline-indicator-button))
    (((class color) (min-colors 88) (background light))
     :background "#aa1111" :foreground "white")
    (((class color) (min-colors 88) (background dark))
     :background "#ff9090" :foreground "black")
    (t :background "red" :foreground "black"))
  "Face for modeline indicators with a background."
  :group 'tim-modeline-faces)

(defface tim-modeline-indicator-green
  '((default :inherit bold)
    (((class color) (min-colors 88) (background light))
     :foreground "#005f00")
    (((class color) (min-colors 88) (background dark))
     :foreground "#73fa7f")
    (t :foreground "green"))
  "Face for modeline indicators."
  :group 'tim-modeline-faces)

(defface tim-modeline-indicator-green-bg
  '((default :inherit (bold tim-modeline-indicator-button))
    (((class color) (min-colors 88) (background light))
     :background "#207b20" :foreground "white")
    (((class color) (min-colors 88) (background dark))
     :background "#77d077" :foreground "black")
    (t :background "green" :foreground "black"))
  "Face for modeline indicators with a background."
  :group 'tim-modeline-faces)

(defface tim-modeline-indicator-yellow
  '((default :inherit bold)
    (((class color) (min-colors 88) (background light))
     :foreground "#6f4000")
    (((class color) (min-colors 88) (background dark))
     :foreground "#f0c526")
    (t :foreground "yellow"))
  "Face for modeline indicators."
  :group 'tim-modeline-faces)

(defface tim-modeline-indicator-yellow-bg
  '((default :inherit (bold tim-modeline-indicator-button))
    (((class color) (min-colors 88) (background light))
     :background "#805000" :foreground "white")
    (((class color) (min-colors 88) (background dark))
     :background "#ffc800" :foreground "black")
    (t :background "yellow" :foreground "black"))
  "Face for modeline indicators with a background."
  :group 'tim-modeline-faces)

(defface tim-modeline-indicator-blue
  '((default :inherit bold)
    (((class color) (min-colors 88) (background light))
     :foreground "#00228a")
    (((class color) (min-colors 88) (background dark))
     :foreground "#88bfff")
    (t :foreground "blue"))
  "Face for modeline indicators."
  :group 'tim-modeline-faces)

(defface tim-modeline-indicator-blue-bg
  '((default :inherit (bold tim-modeline-indicator-button))
    (((class color) (min-colors 88) (background light))
     :background "#0000aa" :foreground "white")
    (((class color) (min-colors 88) (background dark))
     :background "#77aaff" :foreground "black")
    (t :background "blue" :foreground "black"))
  "Face for modeline indicators with a background."
  :group 'tim-modeline-faces)

(defface tim-modeline-indicator-magenta
  '((default :inherit bold)
    (((class color) (min-colors 88) (background light))
     :foreground "#6a1aaf")
    (((class color) (min-colors 88) (background dark))
     :foreground "#e0a0ff")
    (t :foreground "magenta"))
  "Face for modeline indicators."
  :group 'tim-modeline-faces)

(defface tim-modeline-indicator-magenta-bg
  '((default :inherit (bold tim-modeline-indicator-button))
    (((class color) (min-colors 88) (background light))
     :background "#6f0f9f" :foreground "white")
    (((class color) (min-colors 88) (background dark))
     :background "#e3a2ff" :foreground "black")
    (t :background "magenta" :foreground "black"))
  "Face for modeline indicators with a background."
  :group 'tim-modeline-faces)

(defface tim-modeline-indicator-cyan
  '((default :inherit bold)
    (((class color) (min-colors 88) (background light))
     :foreground "#004060")
    (((class color) (min-colors 88) (background dark))
     :foreground "#30b7cc")
    (t :foreground "cyan"))
  "Face for modeline indicators."
  :group 'tim-modeline-faces)

(defface tim-modeline-indicator-cyan-bg
  '((default :inherit (bold tim-modeline-indicator-button))
    (((class color) (min-colors 88) (background light))
     :background "#006080" :foreground "white")
    (((class color) (min-colors 88) (background dark))
     :background "#40c0e0" :foreground "black")
    (t :background "cyan" :foreground "black"))
  "Face for modeline indicators with a background."
  :group 'tim-modeline-faces)

(defface tim-modeline-indicator-gray
  '((t :inherit (bold shadow)))
  "Face for modeline indicators."
  :group 'tim-modeline-faces)

(defface tim-modeline-indicator-gray-bg
  '((default :inherit (bold tim-modeline-indicator-button))
    (((class color) (min-colors 88) (background light))
     :background "#808080" :foreground "white")
    (((class color) (min-colors 88) (background dark))
     :background "#a0a0a0" :foreground "black")
    (t :inverse-video t))
  "Face for modeline indicatovrs with a background."
  :group 'tim-modeline-faces)

(defface tim-modeline-icons-icon
  '((t :inherit (bold fixed-pitch)))
  "Basic attributes for an icon."
  :group 'tim-modeline-icons)

(defface tim-modeline-icons-gray
  '((default :inherit tim-modeline-icons-icon)
    (((class color) (min-colors 88) (background light))
     :foreground "gray30")
    (((class color) (min-colors 88) (background dark))
     :foreground "gray70")
    (t :foreground "gray"))
  "Face for icons."
  :group 'tim-modeline-icons)

(defun tim-modeline-set-faces ()
    "Set face colors in accordance with the active modus or ef theme."
    (modus-themes-with-colors
      (custom-set-faces
       `(tim-modeline-indicator-red ((,c :inherit bold :foreground ,red)))
       `(tim-modeline-indicator-green ((,c :inherit bold :foreground ,green)))
       `(tim-modeline-indicator-yellow ((,c :inherit bold :foreground ,yellow)))
       `(tim-modeline-indicator-blue ((,c :inherit bold :foreground ,blue)))
       `(tim-modeline-indicator-magenta ((,c :inherit bold :foreground ,magenta)))
       `(tim-modeline-indicator-cyan ((,c :inherit bold :foreground ,cyan)))
       `(tim-modeline-indicator-red-bg
	 ((,c :inherit (bold tim-modeline-indicator-button)
              :background ,bg-red-intense :foreground ,fg-main)))
       `(tim-modeline-indicator-green-bg
	 ((,c :inherit (bold tim-modeline-indicator-button)
              :background ,bg-green-intense :foreground ,fg-main)))
       `(tim-modeline-indicator-yellow-bg
	 ((,c :inherit (bold tim-modeline-indicator-button)
              :background ,bg-yellow-intense :foreground ,fg-main)))
       `(tim-modeline-indicator-blue-bg
	 ((,c :inherit (bold tim-modeline-indicator-button)
              :background ,bg-blue-intense :foreground ,fg-main)))
       `(tim-modeline-indicator-magenta-bg
	 ((,c :inherit (bold tim-modeline-indicator-button)
              :background ,bg-magenta-intense :foreground ,fg-main)))
       `(tim-modeline-indicator-cyan-bg
	 ((,c :inherit (bold tim-modeline-indicator-button)
              :background ,bg-cyan-intense :foreground ,fg-main))))))

;;;; Helper Functions

(defun tim-modeline--string-truncate-p (str)
  "Return non-nil value in case the `str' argument should be truncated."
  (let ((window-narrow-p
	 (and (numberp split-width-threshold)
	      (< (window-total-width) split-width-threshold))))
    (cond ((or (not (stringp str))
	       (string-empty-p str)
	       (string-blank-p str))
	   nil)
	  ((and window-narrow-p
		(> (length str) tim-modeline-string-truncate-length)
		(not (one-window-p :no-minibuffer)))))))

(defun tim-modeline--truncate-p ()
  "Return non-nil if truncation should happen.
This is a more general and less stringent variant of
`tim-modeline--string-truncate-p'."
  (and (numberp split-width-threshold)
       (< (window-total-width) split-width-threshold)
       (not (one-window-p :no-minibuffer))))

(defun tim-modeline--first-char (str)
  "Return first character from `str'."
  (substring str 0 1))

(defun tim-modeline-string-cut-middle (str)
  "Return the truncated STR, if appropriate. Else, return
   the unaltered STR."
  (let ((half (floor tim-modeline-string-truncate-length 2)))
    (if (tim-modeline--string-truncate-p str)
	(concat (substring str 0 half) ".." (substring str (- half)))
      str)))

(defun tim-modeline-string-cut-end (str)
  "Return truncated STR, if appropriate, else return STR.
Cut off the end of STR by counting from its start up to
`tim-modeline-string-truncate-length'."
  (if (tim-modeline--string-truncate-p str)
      (concat (substring str 0 tim-modeline-string-truncate-length) "...")
    str))

(defun tim-modeline-string-abbreviate-but-last (str nthlast)
  "Abbreviate `str', keeping `nthlast' words intact."
  (if (tim-modeline--string-truncate-p str)
      (let* ((all-strings (split-string str "[_-]"))
             (nbutlast-strings (nbutlast (copy-sequence all-strings) nthlast))
             (last-strings (nreverse (ntake nthlast (nreverse (copy-sequence all-strings)))))
             (first-component (mapconcat #'tim-modeline--first-char nbutlast-strings "-"))
             (last-component (mapconcat #'identity last-strings "-")))
        (if (string-empty-p first-component)
            last-component
          (concat first-component "-" last-component)))
    str))

;;;; Status Indicator Components

(defvar-local tim-modeline-kbd-macro
    '(:eval
      (when (and (mode-line-window-selected-p) defining-kbd-macro)
        (propertize " KMacro " 'face 'tim-modeline-indicator-blue-bg)))
  "Mode line construct displaying `mode-line-defining-kbd-macro'.
Specific to the current window's mode line.")

(defvar-local tim-modeline-narrow
    '(:eval
      (when (and (mode-line-window-selected-p)
                 (buffer-narrowed-p)
                 (not (derived-mode-p 'Info-mode 'help-mode 'special-mode 'message-mode)))
        (propertize " Narrow " 'face 'tim-modeline-indicator-cyan-bg)))
  "Mode line construct to report the narrowed state of the current buffer.")

(defvar-local tim-modeline-input-method
    '(:eval
      (when current-input-method-title
        (propertize (format " %s " current-input-method-title)
                    'face 'tim-modeline-indicator-green-bg
                    'mouse-face 'mode-line-highlight)))
    "Mode line construct to report the multilingual environment.")

(defvar-local tim-modeline-window-dedicated-status
    '(:eval
      (when (window-dedicated-p)
        (propertize " = "
                    'face 'tim-modeline-indicator-gray-bg
                    'mouse-face 'mode-line-highlight)))
    "Mode line construct for dedicated window indicator.")

(defvar-local tim-modeline-remote
    '(:eval
      (when (file-remote-p default-directory)
        (propertize " @ "
                    'face 'tim-modeline-indicator-red-bg
                    'mouse-face 'mode-line-highlight)))
  "Mode line construct for showing remote file name.")

;;;; Buffer Identifier Component

(defun tim-modeline-buffer-name-help-echo ()
  "Return the `help-echo' value for `tim-modeline-buffer-identifier'."
  (concat
   (propertize (buffer-name) 'face 'mode-line-buffer-id)
   "\n"
   (propertize
    (or (buffer-file-name)
	(format "No underlying file.\nDirectory is: %s" default-directory))
    'face 'font-lock-doc-face)))

(defun tim-modeline-buffer-identification-face ()
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

(defun tim-modeline--buffer-name ()
  "Return `buffer-name', truncating it if necessary."
  (when-let* ((name (buffer-name)))
    (tim-modeline-string-cut-middle name)))

(defvar-local tim-modeline-buffer-identifier
  '(:eval
    (let ((name (propertize (tim-modeline--buffer-name)
			    'face (tim-modeline-buffer-identification-face)
			    'mouse-face 'mode-line-highlight
			    'help-echo (tim-modeline-buffer-name-help-echo)))
	  (read-only-icon
	   (when (and (mode-line-window-selected-p)
		      buffer-read-only)
	     (pcase-let ((`(,icon ,inherent-face)
			  (tim-modeline--icons-get 'read-only)))
	       (format "%2s  " (propertize icon
					 'font-lock-face inherent-face
					 'face inherent-face)))))
	  (file-type-icon
	   (when (and (buffer-file-name)
		      (mode-line-window-selected-p))
	     (require 'nerd-icons)
	     (format "%2s  " (nerd-icons-icon-for-file (buffer-file-name))))))
      (concat read-only-icon file-type-icon name)))
  "Mode line construct for identifying the current buffer.")

;;;; Major Mode Component

(defvar tim-modeline-icons-symbolic
  '((dired-mode "|*" tim-modeline-icons-gray)
    (archive-mode "|@" tim-modeline-icons-gray)
    (diff-mode ">Δ" tim-modeline-icons-gray)
    (prog-mode ">λ" tim-modeline-icons-gray)
    (conf-mode ">λ" tim-modeline-icons-gray)
    (text-mode ">§" tim-modeline-icons-gray)
    (vterm-mode ">>" tim-modeline-icons-gray)
    (comint-mode ">>" tim-modeline-icons-gray)
    (git "" tim-modeline-icons-gray)
    (read-only "" tim-modeline-icons-gray)
    (t ">." tim-modeline-icons-gray))
  "Major modes or concepts and their corresponding icons.
Each element is a cons cell of the form (THING STRING FACE), where THING
is a symbol STRING is one or more characters that represent THING, and
FACE is the face to use for it, where applicable.")

(defun tim-modeline--icons-get (thing)
  "Return `tim-icons-symbolic' representation of `thing'."
  (unless (symbolp thing)
    (error "the thing `%s' is not a symbol" thing))
  (when (string-suffix-p "-mode" (symbol-name thing))
    (while-let ((parent (get thing 'derived-mode-parent)))
      (setq thing parent)))
  (or (alist-get thing tim-modeline-icons-symbolic)
      (alist-get t tim-modeline-icons-symbolic)))

(defun tim-modeline-major-mode-icon ()
  "Return icon for the major mode."
  (pcase-let ((`(,icon ,inherent-face) (tim-modeline--icons-get major-mode)))
    (format "%2s" (propertize icon 'font-lock-face inherent-face 'face inherent-face))))

(defun tim-modeline-major-mode-name ()
  "Return capitalized `major-mode' without the -mode suffix."
  (capitalize (string-replace "-mode" "" (symbol-name major-mode))))

(defun tim-modeline-major-mode-help-echo ()
  "Return `help-echo' value for `tim-modeline-major-mode'."
  (if-let* ((parent (get major-mode 'derived-mode-parent)))
      (format "Symbol: `%s'.  Derived from: `%s'" major-mode parent)
    (format "Symbol: `%s'." major-mode)))

(defvar-local tim-modeline-major-mode
  (list
   (propertize "%[" 'face 'tim-modeline-indicator-red)
   '(:eval
     (concat
      (tim-modeline-major-mode-icon)
      " "
      (propertize
       (tim-modeline-string-abbreviate-but-last
	(tim-modeline-major-mode-name)
	2)
       'mouse-face 'mode-line-highlight
       'help-echo (tim-modeline-major-mode-help-echo))))
   (propertize "%]" 'face 'tim-modeline-indicator-red))
  "Mode line construct for displaying the major mode.")

;;;; Process Component

(defvar-local tim-modeline-process
  (list '("" mode-line-process))
  "Mode line construct for the running process indicator (e.g., compiler
error counter in comint mode).")

;;;; Version Control Component

(declare-function vc-git--symbolic-ref "vc-git" (file))

(defun tim-modeline-vc-branch-name (file backend)
  "Return capitalized VC branch name for FILE with BACKEND."
  (when-let* ((rev (vc-working-revision file backend))
              (branch (or (vc-git--symbolic-ref file)
                          (substring rev 0 7))))
    (capitalize branch)))

(declare-function vc-git-working-revision "vc-git" (file))

(defvar tim-modeline-vc-map
  (let ((map (make-sparse-keymap)))
    (define-key map [mode-line down-mouse-1] 'vc-diff)
    (define-key map [mode-line down-mouse-3] 'vc-root-diff)
    map)
  "Keymap to display on VC indicator.")

(defun tim-modeline-vc-help-echo (file)
  "Return `help-echo' message for FILE tracked by VC."
  (format "Revision: %s\nmouse-1: `vc-diff'\nmouse-3: `vc-root-diff'"
          (vc-working-revision file)))

(defun tim-modeline-vc-text (file branch &optional face)
  "Prepare text for Git controlled FILE, given BRANCH.
With optional FACE, use it to propertize the BRANCH."
  (format "%s %s"
	  (pcase-let ((`(,icon ,inherent-face) (tim-modeline--icons-get 'git)))
	    (propertize icon 'font-lock-face inherent-face 'face inherent-face))
          (propertize branch
                      'face face
                      'mouse-face 'mode-line-highlight
                      'help-echo (tim-modeline-vc-help-echo file)
                      'local-map tim-modeline-vc-map)))

(defun tim-modeline-vc-details (file branch &optional face)
  "Return Git BRANCH details for FILE, truncating it if necessary.
The string is truncated if the width of the window is smaller
than `split-width-threshold'."
  (tim-modeline-string-cut-end
   (tim-modeline-vc-text file branch face)))

(defvar tim-modeline--vc-faces
  '((added . vc-locally-added-state)
    (edited . vc-edited-state)
    (removed . vc-removed-state)
    (missing . vc-missing-state)
    (conflict . vc-conflict-state)
    (locked . vc-locked-state)
    (up-to-date . vc-up-to-date-state))
  "VC state faces.")

(defun tim-modeline-vc-get-face (key)
  "Get face from KEY in `tim-modeline--vc-faces'."
  (alist-get key tim-modeline--vc-faces 'vc-up-to-date-state))

(defun tim-modeline-vc-face (file backend)
  "Return VC state face for FILE with BACKEND."
  (when-let* ((key (vc-state file backend)))
    (tim-modeline-vc-get-face key)))

(defvar-local tim-modeline-vc-branch
    '(:eval
      (when-let* (((mode-line-window-selected-p))
                  (file (or buffer-file-name default-directory))
                  (backend (or (vc-backend file) 'Git))
                  (branch (tim-modeline-vc-branch-name file backend))
                  (face (tim-modeline-vc-face file backend)))
        (tim-modeline-vc-details file branch face)))
    "Mode line construct to return propertized VC branch.")

;;;; Flymake Component

(declare-function flymake--severity "flymake" (type))
(declare-function flymake-diagnostic-type "flymake" (diag))

;; Based on `flymake--mode-line-counter'.
(defun tim-modeline-flymake-counter (type)
  "Compute number of diagnostics in buffer with TYPE's severity.
TYPE is usually keyword `:error', `:warning' or `:note'."
  (let ((count 0))
    (dolist (d (flymake-diagnostics))
      (when (= (flymake--severity type)
               (flymake--severity (flymake-diagnostic-type d)))
        (cl-incf count)))
    (when (cl-plusp count)
      (number-to-string count))))

(defvar tim-modeline-flymake-map
  (let ((map (make-sparse-keymap)))
    (define-key map [mode-line down-mouse-1] 'flymake-show-buffer-diagnostics)
    (define-key map [mode-line down-mouse-3] 'flymake-show-project-diagnostics)
    map)
  "Keymap to display on Flymake indicator.")

(defmacro tim-modeline-flymake-type (type indicator &optional face)
  "Return function that handles Flymake TYPE with stylistic INDICATOR and FACE."
  `(defun ,(intern (format "tim-modeline-flymake-%s" type)) ()
     (when-let* ((count (tim-modeline-flymake-counter
                         ,(intern (format ":%s" type)))))
       (concat
        (propertize ,indicator 'face 'tim-modeline-indicator-gray)
        (propertize count
                    'face ',(or face type)
                    'mouse-face 'mode-line-highlight
                    ;; FIXME 2023-07-03: Clicking on the text with
                    ;; this buffer and a single warning present, the
                    ;; diagnostics take up the entire frame.  Why?
                    'local-map tim-modeline-flymake-map
                    'help-echo "mouse-1: buffer diagnostics\nmouse-3: project diagnostics")
        " "))))

(tim-modeline-flymake-type error "‼")
(tim-modeline-flymake-type warning "!")
(tim-modeline-flymake-type note "!" success)

(defvar-local tim-modeline-flymake
  `(:eval
    (when (and (bound-and-true-p flymake-mode)
               (mode-line-window-selected-p))
      (list
       ;; See the calls to the macro `tim-modeline-flymake-type'
       '(:eval (tim-modeline-flymake-error))
       '(:eval (tim-modeline-flymake-warning))
       '(:eval (tim-modeline-flymake-note)))))
  "Mode line construct displaying `flymake-mode-line-format'.
Specific to the current window's mode line.")

;;;; Eglot Component

(defun tim-modeline-setup-eglot ()
  "Delete `eglot' from the `mode-line-misc-info' field, as we
  manually add a more simplified version of it ourselves using
  `tim-modeline-eglot'."
  (with-eval-after-load 'eglot
    (setq mode-line-misc-info
          (seq-filter (lambda (item)
                        (not (eq (car item) 'eglot--managed-mode)))
                      mode-line-misc-info))
    (setq eglot-mode-line-format
	  '(eglot-mode-line-session
	    eglot-mode-line-error
	    eglot-mode-line-pending-requests
	    eglot-mode-line-progress))
    (setq eglot-code-action-indications '())))

(defvar-local tim-modeline-eglot
    `(:eval
      (when (and (featurep 'eglot)
                 (mode-line-window-selected-p))
	(cl-loop for e in eglot-mode-line-format
              for render = (format-mode-line e)
              unless (eq render "")
              collect (cons render
                            (eq e 'eglot-mode-line-menu))
              into rendered
              finally
              (return (cl-loop for (rspec . rest) on rendered
                               for (r . titlep) = rspec
                               concat r
                               when rest concat (if titlep ":" " • "))))))
  "Mode line construct displaying Eglot information.
Specific to the current window's mode line.")

;;;; Miscellaneous Info Component

(defun tim-modeline-setup-time-display ()
  "Set up the custom configuration for time display used in the
miscelaneous modeline information."
  (setq display-time-format " %a %e %b, %H:%M ")
  (setq display-time-interval 60)
  (setq display-time-default-load-average nil)
  (setq display-time-mail-directory nil)
  (setq display-time-mail-function nil)
  (setq display-time-use-mail-icon nil)
  (setq display-time-mail-string nil)
  (setq display-time-mail-face nil)

  (setq display-time-string-forms
        '((propertize
           (format-time-string display-time-format now)
           'face 'display-time-date-and-time
           'help-echo (format-time-string "%a %b %e, %Y" now))
          " "))

  (display-time-mode 1))

(defvar-local tim-modeline-misc-info
    '(:eval
      (when (mode-line-window-selected-p)
        mode-line-misc-info))
    "Mode line construct displaying `mode-line-misc-info'.
Specific to the current window's mode line.")

;;;; Setting all modeline local variables as risky

;; This is necessary as otherwise `:eval` in modeline
;; components does not work.
(dolist (construct '(tim-modeline-kbd-macro
                     tim-modeline-narrow
                     tim-modeline-input-method
                     tim-modeline-window-dedicated-status
                     tim-modeline-remote
                     tim-modeline-buffer-identifier
		     tim-modeline-major-mode
		     tim-modeline-process
                     tim-modeline-eglot
		     tim-modeline-vc-branch
                     tim-modeline-flymake
                     tim-modeline-misc-info))
  (put construct 'risky-local-variable t))

;;; Entrypoint

;;;###autoload
(defun tim-modeline-setup ()
  "Enable the `tim-modeline' configuration."
  (interactive)
  
  (tim-modeline-setup-eglot)
  (tim-modeline-setup-time-display)
  
  (setq-default mode-line-format
		        '("%e"
                  tim-modeline-kbd-macro
                  tim-modeline-narrow
		          tim-modeline-input-method
                  tim-modeline-window-dedicated-status
                  tim-modeline-remote
		          "  "
		          tim-modeline-buffer-identifier
		          "  "
		          tim-modeline-major-mode
		          tim-modeline-process
                  "  "
		          tim-modeline-vc-branch
                  "  "
                  mode-line-format-right-align
                  tim-modeline-flymake
                  "  "
                  tim-modeline-eglot
                  "  "
                  tim-modeline-misc-info))
  
  (add-hook 'modus-themes-after-load-theme-hook #'tim-modeline-set-faces)
  (tim-modeline-set-faces))

(provide 'tim-modeline)
;;; tim-modeline.el ends here
