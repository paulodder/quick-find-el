(defcustom quick-find-name2dir '(("emacs.d" . "~/.emacs.d")
                                 ("remote/fxr" . "/ssh:paul@168.119.165.84:/home/paul/")
                                 ("remote/plekje-sfs" . "/ssh:paul@37.97.145.128:/home/paul/")
                                 ("remote/lodder.dev" . "/ssh:paul@lodder.dev:/home/paul/")
                                 ("remote/lisa-dl" . "/ssh:lgpu0347@lisa.surfsara.nl:/home/lgpu0347/")
                                 ("dl" . "~/courses/dl/")
                                 ("dl/ass1" . "~/courses/dl/assignments/assignment_1/1_mlp_cnn/")
                                 ("nlp" . "~/courses/nlp1/"))
  "Assocation list of display names with corresponding directory path")

(defun quick-find--sudoify-local (path)
  (let* ((tramp-fname (make-tramp-file-name :user "root"
                                            :domain (system-name))))
    (concat "/sudo:"
            (tramp-file-name-user tramp-fname)
            "@"
            (tramp-file-name-domain tramp-fname)
            ":"
            (expand-file-name path))))

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


(defun quick-find--choose-dir (&optional as-root)
  (let* ((quick-find-names (seq-map 'car quick-find-name2dir))
         (chosen-name (completing-read "Choose: " quick-find-names))
         (chosen-dir (cdr (assoc chosen-name quick-find-name2dir))))
    (if as-root
        (quick-find--sudoify chosen-dir)
      chosen-dir)))



(defun quick-find-file (&optional as-root)
  (interactive)
  (let* ((chosen-dir (quick-find--choose-dir as-root))
         (default-directory chosen-dir))
    (call-interactively 'find-file)))

(defun quick-find-file-as-root ()
  (interactive)
  (quick-find-file t))


(provide 'quick-find)
