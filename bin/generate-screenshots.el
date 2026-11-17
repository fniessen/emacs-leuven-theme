;;; generate-screenshots.el --- Regenerate README screenshots -*- lexical-binding: t; -*-

(require 'org)
(require 'org-agenda)

(defconst leuven-screenshots--root
  (expand-file-name ".." (file-name-directory load-file-name)))

(defconst leuven-screenshots--source
  (concat
   "#+TITLE: Leuven Theme\n"
   "#+AUTHOR: Fabrice Niessen\n"
   "#+STARTUP: showall\n\n"
   "* A pleasant coding environment\n\n"
   "Leuven keeps your notes and code clear and comfortable to read.\n\n"
   "** Capture ideas and keep moving\n\n"
   "- [X] Organize today's priorities\n"
   "- [ ] Review the release checklist\n"
   "- [ ] Share the update with the team\n\n"
   "** Familiar Emacs Lisp, thoughtfully colored\n\n"
   "#+begin_src emacs-lisp\n"
   "(defun leuven-greet (name)\n"
   "  \"Welcome NAME to a focused editing session.\"\n"
   "  (let ((greeting (format \"Hello, %s!\" name)))\n"
   "    (message \"%s\" greeting)))\n"
   "\n"
   "(leuven-greet \"Emacs\")\n"
   "#+end_src\n\n"
   "A little structure makes a big difference.\n"))

(defun leuven-screenshots--capture (buffer filename)
  "Capture BUFFER to FILENAME using the current frame."
  (delete-other-windows)
  (with-current-buffer buffer
    (set-window-buffer (frame-selected-window) buffer))
  (message nil)
  (redisplay t)
  (sit-for 0.2)
  (let ((geometry (format "%dx%d+0+0"
                          (frame-pixel-width)
                          (frame-pixel-height)))
        (output (expand-file-name (concat "images/" filename)
                                  leuven-screenshots--root)))
    (unless (zerop (call-process "import" nil nil nil
                                 "-window" "root" "-crop" geometry
                                 "+repage" output))
      (error "Failed to capture %s" filename))))

(defun leuven-screenshots--source-buffer ()
  "Return a fontified Org buffer for the README source screenshot."
  (let ((buffer (get-buffer-create "*Leuven Screenshot*")))
    (with-current-buffer buffer
      (erase-buffer)
      (insert leuven-screenshots--source)
      (org-mode)
      (setq-local org-fontify-whole-heading-line t)
      (setq-local org-src-fontify-natively t)
      (font-lock-ensure)
      (set-buffer-modified-p nil))
    buffer))

(defun leuven-screenshots--agenda-buffer ()
  "Generate a short real Org agenda for the README screenshot."
  (let* ((file (make-temp-file "leuven-agenda-" nil ".org"))
         (today (current-time))
         (tomorrow (time-add today (days-to-time 1)))
         (later (time-add today (days-to-time 3))))
    (with-temp-file file
      (insert
       (format "* TODO Prepare the weekly plan\nSCHEDULED: <%s>\n\n"
               (format-time-string "%Y-%m-%d" today))
       (format "* TODO Review the release checklist\nDEADLINE: <%s>\n\n"
               (format-time-string "%Y-%m-%d" tomorrow))
       (format "* TODO Share the project update\nSCHEDULED: <%s>\n"
               (format-time-string "%Y-%m-%d" later))))
    (setq org-agenda-files (list file))
    (unwind-protect
        (progn
          (org-agenda-list nil nil 7)
          (get-buffer "*Org Agenda*"))
      (delete-file file))))

(defun leuven-screenshots--prepare-frame ()
  "Set a stable, minimal frame layout for screenshots."
  (let ((frame (selected-frame)))
    (menu-bar-mode -1)
    (when (fboundp 'tool-bar-mode)
      (tool-bar-mode -1))
    (when (fboundp 'scroll-bar-mode)
      (scroll-bar-mode -1))
    (set-frame-parameter frame 'undecorated t)
    (set-frame-parameter frame 'internal-border-width 12)
    (set-frame-size frame 92 42)
    (set-frame-position frame 0 0)
    (raise-frame frame)
    frame))

(defun leuven-screenshots--load-theme (theme)
  "Load THEME for screenshot generation."
  (when custom-enabled-themes
    (mapc #'disable-theme custom-enabled-themes))
  (let ((inhibit-message t))
    (load-file
     (expand-file-name
      (if (eq theme 'leuven)
          "lisp/leuven-theme.el"
        "lisp/leuven-dark-theme.el")
      leuven-screenshots--root))
    (enable-theme theme)))

(defun leuven-screenshots--generate ()
  "Generate the three screenshots referenced by README.org."
  (unless (display-graphic-p)
    (error "Screenshots require a graphical Emacs frame"))
  (leuven-screenshots--prepare-frame)
  (let ((source-buffer (leuven-screenshots--source-buffer)))
    (leuven-screenshots--load-theme 'leuven)
    (leuven-screenshots--capture
     source-buffer "fontified-src-code-blocks.png")
    (leuven-screenshots--capture
     (leuven-screenshots--agenda-buffer) "agenda-and-task-list.png")
    (leuven-screenshots--load-theme 'leuven-dark)
    (leuven-screenshots--capture
     source-buffer "leuven-theme-dark.png")))

(leuven-screenshots--generate)
(kill-emacs 0)

;;; generate-screenshots.el ends here
