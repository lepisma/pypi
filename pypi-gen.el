;; Script for generating pypi repo from the directory structure

(require 'cl-lib)

(defvar pypi-html-template
  "<!DOCTYPE html>
<html>
<head>
  <meta charset=\"UTF-8\">
  <title>%s</title>
</head>
<body>
%s
</body>
</html>"
  "Template for htmls")

(defun pypi-packages ()
  "Return a list of packages found in current dir."
  (cl-remove-if-not #'file-directory-p (directory-files default-directory nil "^[a-z]")))

(defun pypi-package-files (package)
  "Return a list of files for the current package."
  (directory-files (concat default-directory package) nil "[a-z]+\\.\\(whl\\|tar\\.gz\\)"))

(defun pypi-generate-links (items)
  (string-join
   (mapcar (lambda (path) (format "<a href=\"%1$s\">%1$s</a><br>" path))
           (sort items #'string-lessp))
   "\n"))

(defun pypi-generate-master-index ()
  "Generate master index file."
  (let ((packages (pypi-packages)))
    (format pypi-html-template "personal-package-index" (pypi-generate-links packages))))

(defun pypi-generate-package-index (package)
  "Generate index page for given package."
  (let ((files (pypi-package-files package)))
    (format pypi-html-template package (pypi-generate-links files))))

(defun pypi-write (text file)
  (with-temp-file file
    (insert text)))

(defun pypi-generate ()
  (pypi-write (pypi-generate-master-index) "index.html")
  (dolist (package (pypi-packages))
    (pypi-write (pypi-generate-package-index package) (format "%s/index.html" package))))
