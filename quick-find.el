(defcustom quick-find-name2dir '(("emacs.d" . "~/.emacs.d")
                                 ("home" . "~"))
  "Assocation list of display names with corresponding directory path")

(defun quick-find--sudoify-local (path)
  (concat "/sudo:root@localhost:"
          (expand-file-name path)))

(defun quick-find--sudoify-remote (path)
  (let ((tramp-fname (tramp-dissect-file-name path)))
    (concat (string-trim (file-remote-p path)
                         nil
                         ":") ;; ; also has the : should not be htere
            "|sudo:"
            (tramp-file-name-host tramp-fname)
            ":"
            (tramp-file-name-localname tramp-fname))))

(defun quick-find--sudoify (path)
  "makes sudo-equivalent of path"
  (if (file-remote-p path)
      (quick-find--sudoify-remote path)
    (quick-find--sudoify-local path)))

(defun quick-find--choose-name (&optional as-root)
  (let* ((quick-find-names (seq-map 'car quick-find-name2dir)))
    (completing-read "Choose: " quick-find-names)))


(defun quick-find--get-dir-for-name (name)
  (cdr (assoc chosen-name quick-find-name2dir)))

(defun quick-find--choose-dir (&optional as-root)
  (let* ((chosen-name (quick-find--choose-name))
         (chosen-dir (quick-find--get-dir-for-name chosen-name)))
    (if as-root
        (quick-find--sudoify chosen-dir)
      chosen-dir)))

(defun quick-find--get-shell-name (name)
  (concat "shell-" name))

(defun quick-find-file (&optional as-root)
  (interactive)
  (let* ((chosen-dir (quick-find--choose-dir as-root))
         (default-directory chosen-dir))
    (call-interactively 'find-file)))



(defun quick-find-shell (&optional as-root)
  (interactive)
  (let* ((chosen-name (quick-find--choose-name as-root))
         (chosen-dir (quick-find--get-dir-for-name chosen-name))
         (default-directory chosen-dir))
    (shell (quick-find--get-shell-name chosen-name))))

(defun quick-find-file-as-root ()
  (interactive)
  (quick-find-file t))


(provide 'quick-find)
