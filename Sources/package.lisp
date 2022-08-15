;============================================================================
; OM-py
; Use py inside OM
;============================================================================
;
;   This program is free software. For information on usage 
;   and redistribution, see the "LICENSE" file in this distribution.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
;
;============================================================================
; File author: Charles K. Neimog (Univerty  of São Paulo - 2021)
;============================================================================

(in-package :om)

(defpackage "om-python"
  (:use "COMMON-LISP" "CL-USER" "OM")
  (:nicknames :om-py))


; ======================= OM-SHARP Preferences ==================================

(if (equal *app-name* "om-sharp")
  (progn
          (add-preference-section :externals "OM-py" nil '(:py-enviroment :py-scripts :check-updates))
          (add-preference :externals :py-enviroment "Python Enviroment" :path nil)
          (add-preference :externals :py-scripts "Python Scripts" :folder (merge-pathnames "Py-Scripts/" (lib-resources-folder (find-library "OM-py"))))
          (add-preference :externals :check-updates "Online checking of updates" :bool t "If checked, om-py will look for new updates.")))

(if (or (null (get-pref-value :externals :py-enviroment)) (equal (get-pref-value :externals :py-enviroment) ""))
       nil
       #+windows (setq om-py::*activate-virtual-enviroment* (get-pref-value :externals :py-enviroment))
       #+linux (setq (om::string+ ". " (get-pref-value :externals :py-enviroment)))
       #+macos (setq (om::string+ "source " (get-pref-value :externals :py-enviroment))))


