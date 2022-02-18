
(in-package :om-py)





; ==================================
(defun py-list->string (ckn-list)
  (when ckn-list
    (concatenate 'string 
                 (write-to-string (car ckn-list)) (py-list->string (cdr ckn-list)))))

;https://stackoverflow.com/questions/5457346/lisp-function-to-concatenate-a-list-of-strings



(eval (om::flat 
                  (om::get-slot-val 
                     (let
                         (
                              (tb
                                    (om::make-value-from-model 'textbuffer 
                                         (probe-file (merge-pathnames "first-load.txt" (om::lib-resources-folder (om::find-library "OM-py")))) nil)))
                              (setf (om::reader tb) :lines-cols) tb) "CONTENTS")))

; =================================
;; Pip install venv if first load
  
      (if *first-time-load*
            (let* ()
                  (om::save-as-text '(((defvar *first-time-load* nil))) (merge-pathnames "first-load.txt" (om::lib-resources-folder (om::find-library "OM-py"))))
                  (print "Installing venv!")
                  (oa::om-command-line 
                                    #+macosx "pip3 install virtualenv"
                                    #+windows "pip install virtualenv"
                                    #+linux "pip3 install virtualenv"
                                                                  t)
                  ;; Pip create env 
                  (oa::om-command-line 
                                    #+windows (om::string+ "python -m venv " (py-list->string (list (namestring (merge-pathnames "Python/" (om::tmpfile "")))))) t)

;; pip always use venv

                  #+windows (defvar *activate-virtual-enviroment* (namestring (merge-pathnames "Python/Scripts/activate.bat" (om::tmpfile ""))) "nil")
                  #+linux (defvar *activate-virtual-enviroment* (py-list->string (list (namestring (merge-pathnames "Python/Scripts/activate.sh" (om::tmpfile ""))))) "nil")
                  #+macosx (defvar *activate-virtual-enviroment* (py-list->string (list (namestring (merge-pathnames "Python/Scripts/activate.sh" (om::tmpfile ""))))) "nil")

                  (mp:process-run-function (om::string+ "Install om_py")
                              () 
                              (lambda () (oa::om-command-line 
                                                            #+macosx (om::string+ *activate-virtual-enviroment* " && pip3 install om_py") 
                                                            #+windows (om::string+ *activate-virtual-enviroment* " && pip install om_py")
                                                            #+linux (om::string+ *activate-virtual-enviroment* " && pip3 install om_py")
                                                                  t))))
                                                                  
            #+windows (defvar *activate-virtual-enviroment* (namestring (merge-pathnames "Python/Scripts/activate.bat" (om::tmpfile ""))) "nil")
            #+linux (defvar *activate-virtual-enviroment* (py-list->string (list (namestring (merge-pathnames "Python/Scripts/activate.sh" (om::tmpfile ""))))) "nil")
            #+macosx (defvar *activate-virtual-enviroment* (py-list->string (list (namestring (merge-pathnames "Python/Scripts/activate.sh" (om::tmpfile ""))))) "nil")      
                                                            )



;===================================
(defun format2python-v3 (type)
    (case (type-of type)
        (lispworks:simple-text-string (py-list->string (list (list type))))
        (sound (let* (
                      (filepathname (namestring (car (if (not (file-pathname type)) 
                                                         (list (ckn-temp-sounds type (om::string+ "format-" (format nil "~7,'0D" (om-random 0 999999)) "-")))
                                                         (list (file-pathname type)))))))
                                    (om::string+ "r" "'" filepathname "'")))
        (fixnum (write-to-string type))
        (float (write-to-string type))
        (cons (let* (
                        (conteudo (loop :for atom :in type :collect (concatString (om::x-append (format2python-v3 atom) '(", "))))))
                        (concatString (om::x-append "[" conteudo "]"))))
        (single-float (write-to-string type))
        (null " None")
        (pathname  (py-list->string  (list (namestring type))))))

; =================================================

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
        (cons (lisp-list_2_python-list type))
        (single-float (list (write-to-string type)))
        (pathname  (list (namestring type)))))

;==================================

(defun format2python-no-cons (type)
    (case (type-of type)
        (lispworks:simple-text-string (list type))
        (sound (let* (
                      (filepathname (namestring (car (if (not (file-pathname type)) 
                                                         (list (ckn-temp-sounds type (om::string+ "format-" (format nil "~7,'0D" (om-random 0 999999)) "-")))
                                                         (list (file-pathname type)))))))
                                    (om::string+ "r" "'" filepathname "'")))
        (fixnum (write-to-string type))
        (float (write-to-string type))
        (cons (mapcar (lambda (x) (format2python-py-add-var x)) type))
        (single-float (write-to-string type))
        (pathname  (list (namestring type)))))

;==================================

(defun format2python-py-add-var (type)
    (case (type-of type)
        (lispworks:simple-text-string (list type))
        (sound (let* (
                      (filepathname (namestring (car (if (not (file-pathname type)) 
                                                         (list (ckn-temp-sounds type (om::string+ "format-" (format nil "~7,'0D" (om-random 0 999999)) "-")))
                                                         (list (file-pathname type)))))))
                                    (om::string+ "r" "'" filepathname "'")))
        (fixnum (list (write-to-string type)))
        (float (write-to-string type))
        (cons (mapcar (lambda (x) (if (equal (length (om::list! x)) 1)
                                      (caar (format2python-no-cons x))
                                      (format2python x))) type))
        (single-float (list (write-to-string type)))
        (pathname  (list (namestring type)))))


;==================================


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
        (single-float (write-to-string type))
        (pathname   (list (namestring type)))))

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

;(om::defclass! to-om ()
 ;   ((py-inside-om :initform nil :initarg :py-inside-om :accessor py-inside-om)))

;; ================================================ PY CODE INSIDE OM ===========

(om::defclass! py-code ()
    ((code :initform nil :initarg :code :accessor code)))


;; ================ Python Code Editor Inside OM =================

(om::defclass! om2py ()
    ((py-om :initform nil :initarg :py-om :accessor py-om)))

;; ================

(om::defclass! py-externals-mod ()
    ((modules :initform nil :initarg :modules :accessor modules)))

;==================================== STOLEN FUNCTIONS =========================

(defun get-file (filename)
  (with-open-file (stream filename)
    (loop for line = (read-line stream nil)
          while line
          collect line)))

;https://stackoverflow.com/questions/12906738/common-lisp-print-on-one-line-return-single-line-counter-formatting

;====================================

(defun char-by-char (string)

   (loop :for idex :from 0 :to (- (length string) 1)
         :collect 
         (string (aref string idex))))

;https://stackoverflow.com/questions/18065996/loop-over-characters-in-string-common-lisp
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

(defun get-lisp-variables (pathname-of-code)

    (remove nil (loop :for lines :in (get-file pathname-of-code)
                      :collect 
                    (let* (
                          (characters  (char-by-char lines))
                          (is-py-var (equal (om-py::concatstring (om::first-n characters 8)) "#(py_var")))
                          (if is-py-var
                              (om-py::concatstring (cdr characters)))))))

;===============================
(defun remove-lisp-var (pathname-of-code)

    (remove nil (loop :for lines :in (get-file pathname-of-code)
                      :collect 
                    (let* (
                          (characters  (char-by-char lines))
                          (is-py-var (equal (om-py::concatstring (om::first-n characters 8)) "#(py_var")))
                          (if is-py-var
                              nil
                              lines))))) ;;  remove 
        
;===============================

(defun remove-py-var (code var)
  (let* (
        (var-1 (first var))
        (remove-from-code (remove nil (mapcar (lambda (x) (if (null (search var-1 x)) x)) code)))
        (cdr-var (cdr var)))
        (if (null cdr-var)
            remove-from-code
          (remove-py-var remove-from-code cdr-var))))

;; ============

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
    (om::flat (loop :for y :in (om::list! x) :collect 
                              (if 
                                    (equal (type-of y) 'lispworks:simple-text-string)
                                    (read-from-string y)
                                    y)) 1))


; ================================= Import modules functions ======================

(defun pip-install (name)

  (let* ((y-grid 24)
         (win (om::om-make-window 'om::om-dialog :position :centered
                              :resizable t :maximize nil :minimize nil :owner nil
                              :title (format nil "~d The module ~d is not installed! ~d" (string #\NewLine) name (string #\NewLine)))))
    (om::om-add-subviews
     win
     (om::om-make-layout
      'om::om-column-layout
      :subviews
      (list

       (om::om-make-di 'om::om-simple-text
                   :size (om::om-make-point 330 34)
                  ; :font-size
                   :text (format nil "~d Do you want to install ~d ~d?" (string #\NewLine) name (string #\NewLine)))

       (om::om-make-layout
        'om::om-row-layout
        :subviews
        (list
         (om::om-make-di 'om::om-button
                     :size (om::om-make-point 110 y-grid)
                     :text "INSTALL"
                     :default t
                     :di-action #'(lambda (item) (declare (ignore item))
                                    (om::om-return-from-modal-dialog win (list 1))))

         (om::om-make-di 'om::om-button
                     :size (om::om-make-point 110 y-grid)
                     :text (om::om-str :no)
                     :di-action #'(lambda (item) (declare (ignore item))
                                    (om::om-return-from-modal-dialog win (list 0))))
         (om::om-make-di 'om::om-button
                     :size (om::om-make-point 110 y-grid)
                     :text (om::om-str :cancel)
                     :di-action #'(lambda (item) (declare (ignore item))
                                    (om::om-return-from-modal-dialog win (list nil))))
         )))
      ))

    (om::om-modal-dialog win)))

;; ======================================================

(defun list-depth (list)
                (if (listp list)
                    (+ 1 (reduce #'max (mapcar #'list-depth list)
                                 :initial-value 0))
                    0))

; =======================================================
; Functions to be used in the patches METHODS
; =======================================================


(defmethod! run-py ((code om2py) &optional (cabecario nil))
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc "With this object you can see the index parameters of some VST2 plugin."


(if om::*vscode-is-openned* (let () (print "You need to close VScode to update the code")))

(let* (
      (python-code (x-append cabecario (string #\Newline) (om-py::py-om code)))
      (python-name (om::string+ "py-code-temp-" (write-to-string (om-random 10000 999999)) ".py"))
      (data-name (om::string+ "data" (write-to-string (om-random 10000 999999)) ".txt"))
      (save-python-code (om::save-as-text python-code (om::tmpfile python-name :subdirs "om-py")))
      (prepare-cmd-code (py-list->string (list (namestring save-python-code))))
      (where-i-am-running 
                              #+macosx (om::string+ *activate-virtual-enviroment* " && python3 ")
                              #+windows (om::string+ *activate-virtual-enviroment* " && python ")
                              #+linux (om::string+ *activate-virtual-enviroment* " && python3.8 ")))
      (oa::om-command-line (om::string+ where-i-am-running prepare-cmd-code) t)
      (let* (
            (data (om::make-value-from-model 'textbuffer (probe-file (merge-pathnames (user-homedir-pathname) "py_values.txt")) nil)))
            ;(mp:process-run-function "del-py-code" () (lambda (x) (clear-the-file x)) (om::tmpfile python-name :subdirs "om-py"))
            (mp:process-run-function "del-data-code" () (lambda (x) (clear-the-file x)) (merge-pathnames (user-homedir-pathname) "py_values.txt"))
            (read_from_python (if   (null data)        
                                            nil
                                           (om::get-slot-val (let () (setf (om::reader data) :lines-cols) data) "CONTENTS"))))))


;; ================================================

(defmethod! run-py ((code py-code) &optional (cabecario nil))
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc "With this object you can see the index parameters of some VST2 plugin."

(run-py (om::make-value 'om2py (list (list :py-om (code code)))) 
                          (case (type-of cabecario)
                                ('|om-python|::py-externals-mod  (modules cabecario))
                                ('|om-python|::om2py (py-om cabecario))
                                ('|om-python|::py-code (code cabecario))
                                ('string cabecario))))
                                
;; ========================

(defmethod! py-add-var ((function function) &rest rest)
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc ""

(let* (
      (check-all-rest (loop :for type :in (om::list! rest) :collect (format2python-py-add-var type)))
      (py-var (apply 'mapcar function check-all-rest)))
      (om::make-value 'py-code (list (list :code (concatstring (mapcar (lambda (x) (code x)) py-var)))))))

;; ========================

(defmethod! py-concat-code ((codes list))
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc ""

(om::make-value 'py-code (list (list :code (concatString (loop :for all_codes :in codes :collect (code all_codes)))))))



;; ========================

(defmethod! py-add-ext-modules (&key (import nil) (from_import nil) (import* nil))
:initvals '("math" ("math" "sum") "math")
:indoc '("import YOURMODULE" "from YOURMODULE import YOURFUNCTION" "import YOURMODULE*") 
:icon 'py-f
:doc ""
(if   
      (or (= 2 (list-depth from_import)) (null from_import))
            from_import
            (let* ()
            (om::om-message-dialog (format nil "The from_import key seems to be inappropriately formatted!"))
            (om::abort-eval)))

(let* (
      (import-modules (om::x-append 
                                    (om::list! import)
                                    (mapcar (lambda (x) (car x)) from_import)
                                    (mapcar (lambda (x) (car x)) (om::list! import*))))
      (verification-module 
                  (loop :for module :in (om::list! import-modules) 
                        :collect (format nil 
"

try:
    import ~d
except ImportError:
    to_om(f'~d')
    pass  # module doesn't exist, deal with it." module module)))
      
      (om_py (format nil 
"
from om_py import to_om
"))
      (all_code (om-py::concatstring (x-append om_py verification-module)))
      (check-the-modules (om-py::run-py (om::make-value 'om2py (list (list :py-om all_code))))))                 
      (loop :for not_installed :in check-the-modules 
            :do 
                  (let* (
                              (visual-message (pip-install not_installed))
                              (install_modules 
                                    (case (car visual-message)
                                          (1 (om::om-cmd-line 
                                                      #+macosx (format nil "~d && pip3 install ~d" *activate-virtual-enviroment* not_installed)
                                                      #+windows (format nil "~d && pip install ~d" *activate-virtual-enviroment*  not_installed)
                                                      #+linux (format nil "~d && pip3 install ~d" *activate-virtual-enviroment*  not_installed)))
                                          (0 nil)
                                          (nil (om::abort-eval)))))
                                    (if 
                                          (equal install_modules 1) 
                                          (let* () 
                                                      (om::om-message-dialog (format nil "The module ~d was not found, check the spelling!" not_installed))
                                                      (om::abort-eval)))))
      (let* (
            (format-import (loop :for modules :in (om::list! import) :collect (format nil "
import ~d" modules)))
            (format-from_import (loop for modules :in (om::list! from_import) :collect (format nil "
from ~d import ~d" (car modules) (second modules))))
            (all-modules 
                  (concatstring (om::x-append 
"
from om_py import to_om" format-import format-from_import))))
      (om::make-value 'py-externals-mod (list (list :modules all-modules))))))

;==================================

(defmethod! py-mk-list ((list list))
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc ""

(lisp-list_2_python-list list))

;==================================

(defun lista-de-que? (x)

(remove-dup (loop :for class :in x :collect (type-of class)) 'eq 1))


