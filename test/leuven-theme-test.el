;;; leuven-theme-test.el --- Tests for the Leuven themes -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)

(defconst leuven-test--root
  (expand-file-name ".." (file-name-directory (or load-file-name buffer-file-name))))

(defconst leuven-test--magit-faces
  '(magit-left-margin
    magit-mode-line-process
    magit-mode-line-process-error
    magit-process-ng
    magit-process-ok
    magit-section-child-count
    magit-section-heading
    magit-section-heading-selection
    magit-section-highlight
    magit-section-secondary-heading))

(defconst leuven-test--themes
  '((leuven . "lisp/leuven-theme.el")
    (leuven-dark . "lisp/leuven-dark-theme.el")))

(ert-deftest leuven-theme-magit-faces-are-defined ()
  "Both Leuven themes load and define the requested Magit faces."
  (dolist (theme leuven-test--themes)
    (let ((theme-name (car theme)))
      (load-file (expand-file-name (cdr theme) leuven-test--root))
      (let ((settings (get theme-name 'theme-settings)))
        (dolist (face leuven-test--magit-faces)
          (should
           (cl-some (lambda (setting)
                      (and (eq (car setting) 'theme-face)
                           (eq (cadr setting) face)
                           (eq (nth 2 setting) theme-name)))
                    settings)))))))

;;; leuven-theme-test.el ends here
