;; -*- lexical-binding: t -*-
;; Author: Youssef Hesham <m1cr0xf7>

;; avoid silly errors
(set-default-coding-systems 'utf-8)

(setq-default major-mode 'text-mode)

;; change the user-emacs-directory to keep unwanted things out of ~/.emacs.d
(setq user-emacs-directory (expand-file-name "~/.cache/emacs/")
      url-history-file (expand-file-name "url/history" user-emacs-directory)
      package-user-dir "~/.emacs.d/packages")

(defvar user-cache-directory (concat user-emacs-directory "~/.cache/emacs"))

;; autosave
(setq backup-by-copying t    ; don't clobber symlinks
      ;; don't litter my fs tree
      ;; backup-directory-alist '(("." . "~/.emacs.d/saves"))
      make-backup-files nil
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      create-lockfiles nil
      package-native-compile t)

(setq auto-save-file-name-transforms
      `((".*" "~/.emacs.d/saves" t)))


(setq indent-tabs-mode nil
      tab-width 4
      compilation-scroll-output t
      fill-column 80
      isearch-repeat-on-direction-change t
      isearch-wrap-pause 'no-ding)

(setq c-default-style "bsd"
      ;; c-basic-offset 4
)

;; make scrolling less painful
;; (setq scroll-margin 4
;;   scroll-conservatively 0
;;   scroll-up-aggressively 0.01
;;   scroll-down-aggressively 0.01)
;; (setq-default scroll-up-aggressively 0.01
;;   scroll-down-aggressively 0.01)


;; It lets you move point from window to window using Shift and the
;; arrow keys. This is easier to type than ‘C-x o’.
(windmove-default-keybindings)

;; this sets HTML tab to 4 spaces (2 spaces is nice, 4 is ugly)
;; (defvaralias 'sgml-basic-offset 'tab-width)

;; Enable `relative` line numbers
(column-number-mode)
(global-display-line-numbers-mode)
;; (setq display-line-numbers-type 'relative)
;; Use relative numbers only in GUI
;; relative numbers cause unpleasant flickering in terminal emacs.
(if (display-graphic-p)
    (progn
      (setq display-line-numbers-type 'relative)))

;; disable line numbers in these modes
(dolist (mode '(org-mode-hook
		term-mode-hook
		Man-mode-hook
		woman-mode-hook
		shell-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; custom modeline (time-format)
(setq display-time-format "%l:%M: %p %b %y"
      display-time-default-load-average nil)

;; Enable recursive minibuffers
(setq enable-recursive-minibuffers t)

;; Do not allow the cursor in the minibuffer prompt
(setq minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt))
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
;; Emacs 28: Hide commands in M-x which do not work in the current mode.
(setq read-extended-command-predicate
      #'command-completion-default-include-p)

;; mouse config
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ; one line at a time
(setq mouse-wheel-progressive-speed nil) ; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ; scroll window under mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time

;; escape
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
;; hippie expand
;; (global-set-key [remap dabbrev-expand] 'hippie-expand)


;; editor
(defun move-region-internal (arg)
  (cond
   ((and mark-active transient-mark-mode)
    (if (> (point) (mark))
	(exchange-point-and-mark))
    (let ((column (current-column))
	  (text (delete-and-extract-region (point) (mark))))
      (forward-line arg)
      (move-to-column column t)
      (set-mark (point))
      (insert text)
      (exchange-point-and-mark)
      (setq deactivate-mark nil)))
   (t
    (beginning-of-line)
    (when (or (> arg 0) (not (bobp)))
      (forward-line)
      (when (or (< arg 0) (not (eobp)))
	(transpose-lines arg))
      (forward-line -1)))))
(defun move-region-down (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines down."
  (interactive "*p")
  (move-region-internal arg))
(global-set-key (kbd "M-<down>") 'move-region-down)
(defun move-region-up (arg)
  "Move region (transient-mark-mode active) or current line
  arg lines up."
  (interactive "*p")
  (move-region-internal (- arg)))
(global-set-key (kbd "M-<up>") 'move-region-up)
(defun duplicate-line ()
  "duplicate the current line"
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (newline)
  (yank))
(defun delete-ws-and-indent ()
  "delete trailing whitespace and indent the whole buffer"
  (interactive)
  (mark-whole-buffer)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil))
(defun unhighlight-all-in-buffer ()
  "Remove all highlights made by `hi-lock' from the current buffer."
  (interactive)
  (unhighlight-regexp t))
;; highlight / unhighlight
(global-set-key (kbd "C-#") 'highlight-symbol-at-point)
(global-set-key (kbd "C-*") 'unhighlight-all-in-buffer)
(defun kill-thing-at-point (thing)
  "Kill the `thing-at-point' for the specified kind of THING."
  (let ((bounds (bounds-of-thing-at-point thing)))
    (if bounds
	(kill-region (car bounds) (cdr bounds))
      (error "No %s at point" thing))))
(defun kill-symbol-at-point ()
  "Kill symbol at point."
  (interactive)
  (kill-thing-at-point 'symbol))
(defun kill-word-at-point ()
  "Kill word at point."
  (interactive)
  (kill-thing-at-point 'word))
(defun kill-other-buffers ()
  "Kill all other buffers. except the current one."
  (interactive)
  (mapc 'kill-buffer (delq (current-buffer) (buffer-list))))
(defun select-text-in-quote ()
  (interactive)
  (let ( $skipChars $p1 )
    (setq $skipChars "^\"`<>(){}[]")
    (skip-chars-backward $skipChars)
    (setq $p1 (point))
    (skip-chars-forward $skipChars)
    (set-mark $p1)))


;; go to the beginning and the end of current buffer
(global-set-key (kbd "C-{") 'beginning-of-buffer)
(global-set-key (kbd "C-}") 'end-of-buffer)


;; set font
;; WARNING: You should have Fira Code font installed
;; on your system. change the font or delete the following
;; region if you dont want to deal with it
(set-face-attribute 'default nil
		    :family "Fira Code"
		    :weight 'regular
		    :height 110)

(set-fontset-font t 'arabic "Noto Sans Arabic")


;; keybindings emacs way
(global-unset-key "\C-l")
(defvar ctl-l-map (make-keymap)
  "Keymap for local bindings and functions, prefixed by (^L)")
(define-key global-map "\C-l" 'Control-L-prefix)
(fset 'Control-L-prefix ctl-l-map)


;; keybindings emacs way
(global-unset-key "\C-z")
(defvar ctl-z-map (make-keymap)
  "Keymap for local bindings and functions, prefixed by (^Z)")
(define-key global-map "\C-z" 'Control-Z-prefix)
(fset 'Control-Z-prefix ctl-z-map)

(define-key ctl-z-map "z"   'suspend-frame)
(define-key ctl-z-map "u"   'undo-redo)
(define-key ctl-z-map "r"   'undo)
(define-key ctl-z-map "m"   'mark-sexp)

(define-key ctl-z-map "ds"  'kill-symbol-at-point)
(define-key ctl-z-map "dw"  'kill-word-at-point)
(global-set-key (kbd "C-z C-d") 'kill-whole-line)


(global-unset-key "\C-\\")
(defvar ctl-backslash-map (make-keymap)
  "Keymap for local bindings and functions, prefixed by \ (backslash)")
(define-key global-map "\C-\\" 'Control-Backslash-prefix)
(fset 'Control-Backslash-prefix ctl-backslash-map)

;; Common keybindings
(define-key ctl-l-map "l"   'recenter-top-bottom)
(define-key ctl-l-map "g"   'goto-line)
(define-key ctl-l-map "R"   'replace-regexp)
(define-key ctl-l-map "Q"   'query-replace-regexp)
(define-key ctl-l-map "T"   'delete-trailing-whitespace)
(define-key ctl-l-map "k"   'kill-current-buffer)
(define-key ctl-l-map "fr"  'fill-region)
(define-key ctl-l-map "ee"  'async-shell-command)
(define-key ctl-l-map "er"  'shell-command-on-region)
(define-key ctl-l-map "sq"  'select-text-in-quote)


(define-key ctl-backslash-map "m" 'man)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")
			 ("org" . "https://orgmode.org/elpa/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; External Packages (use-package)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

;; add themes directory
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
;; load the theme
;; (load-theme 'less t)
;; (load-theme 'modus-vivendi t)
(load-theme 'leyl t)


(use-package diminish :ensure t)
(use-package markdown-mode :ensure t)
(use-package js2-mode :ensure t)

(use-package yasnippet
  :ensure t
  :diminish t
  :config
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))  ;; personal snippets
  (yas-reload-all)
  (add-hook 'prog-mode-hook #'yas-minor-mode)
  (diminish 'yas-minor-mode)
  (defun yasnippet-snippets--fixed-indent ()
    "Set `yas-indent-line' to `fixed'."
    (set (make-local-variable 'yas-indent-line) 'fixed)))

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 4.0))

(use-package undo-tree
  :ensure t
  :diminish
  :init
  (global-undo-tree-mode 1)
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo"))))

(define-key ctl-backslash-map "dl" 'dired-find-file)
(define-key ctl-backslash-map "dh" 'dired-up-directory)
(define-key ctl-backslash-map "dd" 'dired-do-delete)
(define-key ctl-backslash-map "dM" 'dired-do-chmod)
(define-key ctl-backslash-map "dt" 'dired-do-touch)
(define-key ctl-backslash-map "dr" 'dired-do-rename)

(global-set-key (kbd "C-,") 'duplicate-line)

;; easier way to navigate
(global-set-key (kbd "M-[") 'backward-paragraph)
(global-set-key (kbd "M-]") 'forward-paragraph)

(global-set-key (kbd "M-s s") 'isearch-forward)

;; Example configuration for Consult
(use-package consult
  :ensure t
  :bind (
	 ;; C-x bindings (ctl-x-map)
	 ("C-x b" . consult-buffer)		   ;; orig. switch-to-buffer
	 ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
	 ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
	 ("C-x p b" . consult-project-buffer)	   ;; orig. project-switch-to-buffer
	 ;; M-g bindings (goto-map)
	 ("M-g g" . consult-goto-line)		   ;; orig. goto-line
	 ("M-g m" . consult-mark)
	 ("M-g k" . consult-global-mark)
	 ("M-g i" . consult-imenu)
	 ("M-g I" . consult-imenu-multi)
	 ;; M-s bindings (search-map)
	 ("M-s g" . consult-grep)
	 ("C-s" . consult-line)
	 ("M-s L" . consult-line-multi))
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
	xref-show-definitions-function #'consult-xref))

;; Enable vertico
(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-package orderless
  :ensure t
  :init
  (setq completion-styles '(orderless)
	completion-category-defaults nil
	completion-category-overrides '((file (styles partial-completion)))))

(use-package savehist
  :ensure t
  :init
  (savehist-mode))

(define-key ctl-backslash-map "tw"  'whitespace-mode)
(define-key ctl-backslash-map "tt"  'consult-theme)

(use-package diff-hl
  :ensure t
  :init
  :defer
  (global-diff-hl-mode))

(use-package magit
  :ensure t
  :defer t
  :commands (magit-status magit-get-current-branch))

(define-key ctl-backslash-map "gs"  'magit-status)
(define-key ctl-backslash-map "gd"  'magit-diff-unstaged)
(define-key ctl-backslash-map "glc" 'magit-log-current)
(define-key ctl-backslash-map "glf" 'magit-log-buffer-file)
(define-key ctl-backslash-map "gb"  'magit-branch)

(use-package rust-mode :ensure t)
(use-package go-mode :ensure t)

(use-package flycheck
  :ensure t
  :defer t
  :hook (lsp-mode . flycheck-mode))

(define-key ctl-backslash-map "ae"  'global-flycheck-mode)
(define-key ctl-backslash-map "aE"  'list-flycheck-errors)

(use-package company
  :ensure t
  :diminish
  :init

  (global-company-mode)
  (define-key ctl-z-map "n" 'company-complete))


(define-key ctl-backslash-map "ld" 'xref-find-definitions)
(define-key ctl-backslash-map "lr" 'xref-find-references)
(define-key ctl-backslash-map "ls" 'consult-imenu)

;; comments
(define-key ctl-backslash-map "c " 'comment-line)
(define-key ctl-backslash-map "cb" 'comment-box)
(define-key ctl-backslash-map "ca" 'comment-dwim)

;; Highlight Codetags
(add-hook 'prog-mode-hook
	  (lambda ()
	    (font-lock-add-keywords nil '(("\\<\\(FIXME\\|XXX\\|DEBUG\\|BUG\\|TODO\\|REFERENCE\\|WONTFIX\\|NOTE\\):" 1 font-lock-warning-face t)))))

;; ;; Whitespace style
(setq whitespace-style '(face
			 tabs
			 spaces
			 trailing
			 space-mark
			 ;; newline
			 indentation
			 tab-mark))

(define-key ctl-l-map "cc" 'compile)
(define-key ctl-l-map "cr" 'recompile)

;; when compiling open a new buffer and switch
;; to the buffer automatically
;; without any fancy splits or anything
(setq special-display-buffer-names
      '("*compilation*"))

(setq special-display-function
      (lambda (buffer &optional args)
	;; (split-window)
	(switch-to-buffer buffer)
	(get-buffer-window buffer 0)))

(setq comment-auto-fill-only-comments t)

(auto-fill-mode t)
