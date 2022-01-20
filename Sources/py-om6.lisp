;============================================================================
; om#: visual programming language for computer-assisted music composition
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
; File author: J. Bresson adapted by Charles K. Neimog
;============================================================================


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


(in-package :om-py)

;; ================= Some Functions =====================

(defun lisp-list_2_python-list (list)
      "Transform a list in lisp to a list in Python."
(let* (
      (list2string (mapcar (lambda (x) (write-to-string x)) list)))
      (loop :for x :in list2string :collect (om::string+ x ", "))))

;; ========================

(defun lisp->list-py-run (list)
      "Transform a list in lisp to a list in Python."
      (om::flat (loop :for x :in list :collect (x-append x ", "))))


;; ================================================ BRING TO OM ===========

(om::defclass! to-om ()
    ((py-inside-om :initform nil :initarg :py-inside-om :accessor py-inside-om)))

;; ================================================ PY CODE INSIDE OM ===========

(om::defclass! py-code ()
    ((code :initform nil :initarg :code :accessor code)))


;; ================ Python Code Editor Inside OM =================

(om::defclass! om2py ()
    ((py-om :initform nil :initarg :py-om :accessor py-om)))

;; ================

(om::defclass! py-externals-mod ()
    ((modules :initform nil :initarg :modules :accessor modules)))


;====================================
;==================================== 
;====================================
;==================================== 
;==================================== Stolen Functions
;==================================== 


(defun py-list->string (ckn-list)
  (when ckn-list
    (concatenate 'string 
                 (write-to-string (car ckn-list)) (py-list->string (cdr ckn-list)))))

; https://stackoverflow.com/questions/5457346/lisp-function-to-concatenate-a-list-of-strings
;====================================

(defun concatString (list)
  "A non-recursive function that concatenates a list of strings."
  (if (listp list)
      (let ((result ""))
        (dolist (item list)
          (if (stringp item)
              (setq result (concatenate 'string result item))))
        result)))

;; https://stackoverflow.com/questions/5457346/lisp-function-to-concatenate-a-list-of-string
;===================================================================== Files control =====================================

(defun py-name-of-file (p)
  (let ((path (and p (pathname p))))
  (when (pathnamep path)
    (om::string+ (pathname-name path) 
             (if (and (pathname-type path) (stringp (pathname-type path)))
                 (om::string+ "." (pathname-type path)) 
               "")))))
               
;; ============

(defun clear-all-temp-files ()

(let* ()
            (mp:process-run-function (om::string+ "Clear Temp Files " (write-to-string (om-random 1 1000)))
                 () 
                        (lambda () (oa::om-delete-directory (merge-pathnames "om-py/" (tmpfile ""))) nil))
            (ensure-directories-exist (tmpfile " " :subdirs "\om-py"))))


                                          
;; ================================

(defun clear-the-file (thefile)

"This delete the file in other thread that not the main of OM."

(mp:process-run-function (om::string+ "Clear Temp Files" (write-to-string (om-random 1 1000)))
                 () 
                 (lambda (x) (alexandria::delete-file thefile)) thefile))
 
;================================== WAIT PROCESS =================

(defun loop-until-probe-file (my-file)
        (loop :with file = nil 
              :while (equal nil (setf file (probe-file my-file)))
        :collect file)
        
(probe-file my-file))

;==========================

(defun loop-until-finish-process (mailbox)
      (loop :with mailbox-empty = nil :while 
            (setf mailbox-empty (remove nil (mapcar (lambda (x) (mp:mailbox-empty-p x)) mailbox)))
            :do (let* ()
            mailbox-empty)))

;================================== WAIT PROCESS =================

(defun read_from_python (x) 
    (loop :for y :in (om::list! x) :collect 
                              (if 
                                    (equal (type-of y) 'lispworks:simple-text-string)
                                    (read-from-string y)
                                    y)))

; =======================================================
; Functions to be used in the patches METHODS
; =======================================================

(defmethod! run-py ((code om2py) &optional (cabecario nil))
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc "With this object you can see the index parameters of some VST2 plugin."

(run-py (om::make-value 'to-om (list (list :py-inside-om (py-om code)))) cabecario))

;; ================================================

(defmethod! run-py ((code py-code) &optional (cabecario nil))
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc "With this object you can see the index parameters of some VST2 plugin."

(read_from_python (run-py (om::make-value 'to-om (list (list :py-inside-om (code code)))) 
                          (if (equal (type-of cabecario) '|om-python|::py-externals-mod)
                              (modules cabecario)
                              cabecario))))

;; ========================

(defmethod! run-py ((code to-om) &optional (cabecario nil))
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc ""

(let* (
      (python-code (x-append cabecario " 

" (py-inside-om code)))
      (python-name (om::string+ "py-code-temp-" (write-to-string (om-random 10000 999999)) ".py"))
      (data-name (om::string+ "data" (write-to-string (om-random 10000 999999)) ".txt"))
      (save-python-code (om::save-as-text python-code (om::tmpfile python-name :subdirs "om-ckn")))
      (prepare-cmd-code (py-list->string (list (namestring save-python-code)))))
      (where-i-am-running 
                              #+macosx "python3 " 
                              #+windows "python "
                              #+linux "python3 "))
      (oa::om-command-line (om::string+ where-i-am-running prepare-cmd-code) t)
      (let* (
            (data (om::make-value-from-model 'textbuffer (merge-pathnames (user-homedir-pathname) "py_values.txt") nil)))
            (mp:process-run-function "del-py-code" () (lambda (x) (clear-the-file x)) (om::tmpfile python-name :subdirs "om-py"))
            (mp:process-run-function "del-data-code" () (lambda (x) (clear-the-file x)) (merge-pathnames (user-homedir-pathname) "py_values.txt"))
            (read_from_python (om::contents data))))

;; ========================

(defmethod! py-add-var ((function function) &rest rest)
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc ""
(let* (
      (check-all-rest (loop :for type :in (om::list! rest) :collect (add-var-format type)))
      (py-var (apply 'mapcar function check-all-rest)))
      (om::make-value 'py-code (list (list :code (concatstring (mapcar (lambda (x) (py-om x)) py-var)))))))

;; ========================

(defmethod! py-add-ext-mod ((list list) &rest rest)
:initvals '(nil)
:indoc '("add externals modules to Python") 
:icon 'py-f
:doc ""

(om::make-value 'py-externals-mod (list (list :modules (x-append list rest)))))


;; ========================

(defmethod! py-add-ext-mod ((list string) &rest rest)
:initvals '(nil)
:indoc '("add externals modules to Python") 
:icon 'py-f
:doc ""

(om::make-value 'py-externals-mod (list (list :modules (x-append list rest)))))


;==================================

(defun add-var-format (type)
    (case (type-of type)
        (lispworks:simple-text-string (list type))
        (sound (let* (
                      (filepathname (namestring (car (if (not (file-pathname type)) 
                                                         (list (ckn-temp-sounds type (om::string+ "format-" (format nil "~7,'0D" (om-random 0 999999)) "-")))
                                                         (list (file-pathname type)))))))
                                    (om::string+ "r" "'" filepathname "'")))
        (fixnum (list (write-to-string type)))
        (float (write-to-string type))
        (cons (flat (mapcar (lambda (x) (list (add-var-format x))) type)))
        (single-float (list (write-to-string type)))
        (pathname  (list (namestring type)))))

;==================================

(defun format2python (type)
    (case (type-of type)
        (lispworks:simple-text-string (list type))
        (sound (let* (
                      (filepathname (namestring (car (if (not (file-pathname type)) 
                                                         (list (ckn-temp-sounds type (om::string+ "format-" (format nil "~7,'0D" (om-random 0 999999)) "-")))
                                                         (list (file-pathname type)))))))
                                    (om::string+ "r" "'" filepathname "'")))
        (fixnum (list (write-to-string type)))
        (float (write-to-string type))
        (cons (lisp->list-py-run (flat (mapcar (lambda (x) (list (format2python x))) type))))
        (single-float (list (write-to-string type)))
        (pathname   (list (namestring type)))))


;; ==========================================================