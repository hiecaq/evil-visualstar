;;; evil-visualstar.el --- Starts a * or # search from the visual selection  -*- lexical-binding: t; -*-

;; Copyright (C) 2013 by Bailey Ling
;; Author: Bailey Ling
;; URL: https://github.com/bling/evil-visualstar
;; Filename: evil-visualstar.el
;; Description: Starts a * or # search from the visual selection
;; Created: 2013-09-24
;; Version: 0.2.0
;; Keywords: evil vim visualstar
;; Package-Requires: ((evil "0"))
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Commentary:
;;
;; Install:
;; (require 'evil-visualstar)
;;
;; Usage:
;;
;; (global-evil-visualstar-mode t)
;;
;; Make a visual selection with `v` or `V`, and then hit `*` to search
;; the selection forward, or # to search that selection backward.
;;
;; If the evil-visualstar/persistent option is not nil, visual-state
;; will remain in effect, allowing for repeated * or #.

;;; Code:

(require 'evil)

(defgroup evil-visualstar nil
  "evil-visualstar configuration options."
  :prefix "evil-visualstar"
  :group 'evil)

(defcustom evil-visualstar/persistent nil
  "Set to `t` if `*` and `#` should keep visual-mode.
That would visually-select the found occurrence, allowing for
repeated searches.
You will need to hit escape to leave visual-mode."
  :group 'evil-visualstar
  :type 'boolean)

(defun evil-visualstar/begin-search (beg end direction symbol)
  (when (evil-visual-state-p)
    (evil-exit-visual-state))
  (let ((found)
        (selection (format (if symbol "\\_<%s\\_>" "\\<%s\\>")
                           (regexp-quote (buffer-substring-no-properties beg end)))))
    (if (eq evil-search-module 'isearch)
        (progn
          (setq isearch-forward direction)
          (setq found (evil-search selection direction t)))
      (let ((pattern (evil-ex-make-search-pattern selection))
            (direction (if direction 'forward 'backward)))
        (setq evil-ex-search-direction direction)
        (setq evil-ex-search-pattern pattern)
        (evil-ex-search-activate-highlight pattern)
        ;; update search history unless this pattern equals the
        ;; previous pattern
        (unless (equal (car-safe evil-ex-search-history) selection)
          (push selection evil-ex-search-history))
        (evil-push-search-history selection (eq direction 'forward))
        (setq found (evil-ex-search-next))))
    (when (and evil-visualstar/persistent found)
      (push-mark (+ (point) (- end beg)) nil t))))

(evil-define-operator evil-visualstar-operator-backward-symbol (beg end)
  "Search for motion forwards."
  :repeat nil
  :keep-visual nil
  (evil-visualstar/begin-search beg end nil t))

(evil-define-operator evil-visualstar-operator-forward-symbol (beg end)
  "Search for motion forwards."
  :repeat nil
  :keep-visual nil
  (evil-visualstar/begin-search beg end t t))

(evil-define-operator evil-visualstar-operator-backward (beg end)
  "Search for motion forwards."
  :repeat nil
  :keep-visual nil
  (evil-visualstar/begin-search beg end nil nil))

(evil-define-operator evil-visualstar-operator-forward (beg end)
  "Search for motion forwards."
  :repeat nil
  :keep-visual nil
  (evil-visualstar/begin-search beg end t nil))

(provide 'evil-visualstar)
;;; evil-visualstar.el ends here
