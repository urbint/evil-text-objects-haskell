;;; evil-text-objects-haskell.el --- Text objects for Haskell source code

;;; License:

;; Copyright (C) 2018 Off Market Data, Inc. DBA Urbint
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to
;; deal in the Software without restriction, including without limitation the
;; rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
;; sell copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
;; IN THE SOFTWARE.

;;; Commentary:

;; evil-text-objects-haskell provides text-object definitions that
;; should make working with Haskell in Emacs more enjoyable.
;;
;; Currently supporting:
;;   - functions
;;   - multi-line comments
;;
;; See the README.md for installation instructions.

(require 'evil)
(require 'pcre2el)
(require 'dash)
(require 'bind-key)

;;; Code:

;; Helper Functions
(defun string-symbol-at-point ()
  "Return a string version of the symbol at point after stripping away
after all of the text properties."
  (->
   (symbol-at-point)
   symbol-name
   substring-no-properties))

;; multi-line comments
(evil-define-text-object
  evil-inner-haskell-comment-block (count &optional beg end type)
  "Inner text object for a Haskell comment block."
  (let ((beg (save-excursion
               (search-backward "{-")
               (right-char 2)
               (point)))
        (end (save-excursion
               (search-forward  "-}")
               (left-char 2)
               (point))))
    (evil-range beg end type)))

(evil-define-text-object
  evil-outer-haskell-comment-block (count &optional beg end type)
  "Outer text object for a Haskell comment block."
  (let ((beg (save-excursion
               (search-backward "{-")
               (point)))
        (end (save-excursion
               (search-forward  "-}")
               (point))))
    (evil-range beg end type)))

;; functions
(evil-define-text-object
  evil-inner-haskell-function (count &optional beg end type)
  "Inner text object for a Haskell function."
  (evil-range 0 0 type))

(evil-define-text-object
  evil-outer-haskell-function (count &optional beg end type)
  "Outer text object for a Haskell function."
  (beginning-of-line)
  (when (looking-at "--")
    (while (looking-at "--")
      (forward-line -1)))
  (when (looking-at "[[:space:]]")
    (while (looking-at "[[:space:]]")
      (forward-line -1)))
  (let* ((fn-name (save-excursion
                    (search-backward-regexp "^\\w")
                    (string-symbol-at-point)))
         (fn-name-regexp (concat "^" fn-name "\\b"))
         (end (save-excursion
                (while (search-forward-regexp fn-name-regexp nil t))
                (unless (search-forward-regexp "^\\w" nil t)
                  (goto-char (point-max)))
                (search-backward-regexp "^[[:space:]]+[^ ]")
                (end-of-line)
                (point)))
         (beg (save-excursion
                (goto-char end)
                (while (search-backward-regexp fn-name-regexp nil t))
                (beginning-of-line)
                (forward-line -1)
                (while (looking-at "--")
                  (forward-line -1))
                (point))))
    (evil-range beg end type)))

;; Installation Helper
(defun evil-text-objects-haskell/install ()
  "Register keybindings for the text objects defined herein.  It is
recommended to run this after something like `haskell-mode-hook'.  See
README.md for additional information."
  (bind-keys :map evil-operator-state-local-map
             ("af" . evil-outer-haskell-function)
             ("if" . evil-inner-haskell-function)
             ("iC" . evil-inner-haskell-comment-block)
             ("aC" . evil-outer-haskell-comment-block))
  (bind-keys :map evil-visual-state-local-map
             ("af" . evil-outer-haskell-function)
             ("if" . evil-inner-haskell-function)
             ("iC" . evil-inner-haskell-comment-block)
             ("aC" . evil-outer-haskell-comment-block)))

(provide 'evil-text-objects-haskell)

;;; evil-text-objects-haskell.el ends here
