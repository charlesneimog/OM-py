
(in-package :om-py)


(setf om_py-threading_work nil)

; ==================================
(defun py-list->string (ckn-list)
  (when ckn-list
    (concatenate 'string 
                 (write-to-string (car ckn-list)) (py-list->string (cdr ckn-list)))))

;https://stackoverflow.com/questions/5457346/lisp-function-to-concatenate-a-list-of-strings

; ================================= FIRST LOAD?? ================================================================

(let* (
      (file-exits? (probe-file (merge-pathnames "first-load.txt" (om::lib-resources-folder (om::find-library "om-py"))))))
      (setf *first-time-load* file-exits?)
      (if file-exits? 
            (delete-file file-exits?)))

; ================================= VIRTUAL ENV =================================================================
                              
#+windows (defvar *activate-virtual-enviroment* (py-list->string (list (namestring (merge-pathnames "OM-py-env/Scripts/activate.bat" (om::tmpfile ""))))) "nil")
#+linux (defvar *activate-virtual-enviroment* (om::string+ ". " (namestring (merge-pathnames "OM-py-env/bin/activate" (om::tmpfile "")))) "nil")
#+mac (defvar *activate-virtual-enviroment* (om::string+ "source " (namestring (merge-pathnames "OM-py-env/bin/activate" (om::tmpfile "")))) "nil")

; =================================
;; Pip install venv if first load
(if *first-time-load*
      (progn
            ; "Check if it is the first time of the load!"
            (print "Installing venv!")
            (oa::om-command-line 
                        #+mac "python3 -m pip install virtualenv"
                        #+windows "pip install virtualenv"
                        #+linux "sudo apt install python3 venv -S"
                                                                  t)
                  ;; Pip create env 
            
            (oa::om-command-line 
                  #+mac  (om::string+ "python3 -m venv " (namestring (merge-pathnames "OM-py-env/" (om::tmpfile ""))))
                  #+windows (om::string+ "python -m venv " (py-list->string (list (namestring (merge-pathnames "OM-py-env/" (om::tmpfile ""))))))
                  #+linux (om::string+ "python3 -m venv " (namestring (merge-pathnames "OM-py-env/" (om::tmpfile ""))))                                          
                                              t)
            
            (sleep 5)

            (if (equal (software-type) "Darwin")
                  
                  (progn
                  ;(print "I am on MacOS!!")

                  (mp:process-run-function "Install OM_py!"
                                   () 
                                          (lambda () (progn
                                                            (sleep 2)                                      
                                                            (om::om-shell (om::string+ *activate-virtual-enviroment* " && python3 -m pip install om_py")))))))
                                    
;; pip always use venv

            (oa::om-command-line 
                  #+mac (om::string+ *activate-virtual-enviroment* " && python3 -m pip install om_py") 
                  #+windows (om::string+ *activate-virtual-enviroment* " && pip install om_py")
                  #+linux (om::string+ *activate-virtual-enviroment* " && pip3 install om_py")
                              t)))
        

;===================================
(defun save-temp-sounds (sounds &optional if-needed) 
      "It save sounds in a temp folder using random numbers."

    (let* (
            (first-action1 (mapcar 
                    (lambda (x) (om::string+ "Sound-" if-needed x))
                        (mapcar (lambda (x) (format nil "~6,'0D" x)) (om::arithm-ser 1 (length (om::list! sounds)) 1)))))
      
            (loop :for loop-sound :in (om::list! sounds)
                :for loop-names :in first-action1
                :collect (om:save-sound loop-sound (merge-pathnames "om-py/" (om::tmpfile (om::string+ loop-names ".wav"))))))) 
                
                ;; TODO add (get-pref-value :Audio :format)

;===================================
(defun format2python-v3 (type)
      "This is the function to format the lisp and OM code and classes to be used in Python."

    (case (type-of type)
            (lispworks:simple-text-string (if (null (probe-file type))
                                          (py-list->string (list type))
                                          (py-list->string (list (namestring type)))))
            (sound (let* (
                      (filepathname (namestring (car (if (not (om::file-pathname type)) 
                                                         (om::list! (save-temp-sounds type (om::string+ "format-" (format nil "~7,'0D" (om-random 0 999999)) "-")))
                                                         (om::list! (om::file-pathname type)))))))
                                    (om::string+ "r" "'" filepathname "'")))
            (fixnum (write-to-string type))
            (float (write-to-string type))
               
            (cons (let* (
                        (conteudo (loop :for atom :in type :collect (concatString (om::x-append (format2python-v3 atom) '(", "))))))
                        (concatString (om::x-append "[" conteudo "]"))))
            (single-float (write-to-string type))
            (null " None")
            (symbol (if (equal type 't) " True" type)) 
            ('om::pure-data (py-list->string  (list (namestring (om::pd-path type))))) ;; It will need of OM-CKN????????????? I think not!
            (pathname  (py-list->string  (list (namestring type))))
            ((unsigned-byte 16) (write-to-string type))
            
            (otherwise (progn 
                                                (om::om-print "format2python: type not found! Please report to charlesneimog@outlook.com" "ERROR")
                                                (write-to-string type)
                                                
                                                ))

            ))





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


;; ================================================ PY CODE INSIDE OM ===========

(om::defclass! python ()

    ((code :initform nil :initarg :code :accessor code))
    (:documentation "This class will have all the code created!"))

;(:documentation "This class will have all the code created!")

;; ================

(om::defclass! py-externals-mod ()
    ((modules :initform nil :initarg :modules :accessor modules))
    (:documentation "This class will have all the external modules used and maybe some functions used in the python class, all things that are used in your python code and could not be repeated."))

;==================================== STOLEN FUNCTIONS =========================

(defun read-python-script-lines (filename)
      "Return the content of a file as a string."
      (remove nil 
            (with-open-file (stream filename)
                  (loop for line = (read-line stream nil) 
                        while line
                        collect line))))

;https://stackoverflow.com/questions/12906738/common-lisp-print-on-one-line-return-single-line-counter-formatting

;====================================

(defun char-by-char (string)
      "Return a list of characters of a string (one by one)."
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

;; ======================================================

(defun get-lisp-variables (pathname-of-code)

    (remove nil (loop :for lines :in (read-python-script-lines pathname-of-code)
                      :collect 
                    (let* (
                          (characters  (char-by-char lines))
                          (is-py-var (equal (om-py::concatstring (om::first-n characters 8)) "#(py_var")))
                          (if is-py-var
                              (om-py::concatstring (cdr characters)))))))

;; ======================================================

(defun list-depth (list)
      "Returns the depth of a list."
      (if (listp list)
            (+ 1 (reduce #'max (mapcar #'list-depth list)
                        :initial-value 0))
                    0))

;=====================================================================

(defun remove-lisp-var (pathname-of-code)

    (remove nil (loop :for lines :in (read-python-script-lines pathname-of-code)
                      :collect 
                    (let* (
                          (characters  (char-by-char lines))
                          (is-py-var (equal (om-py::concatstring (om::first-n characters 8)) "#(py_var")))
                          (if is-py-var
                              nil
                              lines))))) ;;  remove 
        
;===============================

(defun remove-py-var (code var)
"It removes the variables between comment in the begin of the python code."

  (let* (
        (var-1 (first var))
        (remove-from-code (remove nil (mapcar (lambda (x) (if (null (search var-1 x)) x)) code)))
        (cdr-var (cdr var)))
        (if (null cdr-var)
            remove-from-code
          (remove-py-var remove-from-code cdr-var))))
               
;; ============

(defun clear-all-temp-files ()

"It removes all the temp files created by om-py inside the om-py folder."
(progn
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

"This function is used to wait until the file is created."
        (loop :with file = nil 
              :while (equal nil (setf file (probe-file my-file)))
        :collect file)
        
(probe-file my-file))

;================================================================

(defun read_from_python (x) 
      (let* (
            (PythonOutput (om::flat       
                              (loop :for y :in (om::list! x) 
                                    :collect 
                                          (if 
                                                (equal (type-of y) 'lispworks:simple-text-string)
                                                (read-from-string y)
                                                y)) 1)))
            (if (equal (length PythonOutput) 1)
                  (first PythonOutput)
                  PythonOutput)))

; ================================= Import modules functions ======================

(defun pip-install (name)

"It installs a module in the python environment."

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

; =======================================================
; Functions to be used in the patches METHODS
; =======================================================

(defun start-python-print-server ()
"It starts the python print server it must be used with om_print() function in om_py module."

(om::om-start-udp-server 1995 "127.0.0.1" 
            (lambda (msg) (progn 
                              (om::om-print (om::string+ (write-to-string (car (cdr (om::osc-decode msg)))) (string #\Newline)) "Python")  
                              nil))))

; =======================================================

(defun stop-python-print-server ()
"It stops the python print server initalized by start-python-print-server."

(loop :for udp-server :in om::*running-udp-servers*
                  :do (if (equal (mp:process-name (third udp-server)) "UDP receive server on \"127.0.0.1\" 1995")
                        (om::om-stop-udp-server (third udp-server)))))

; =======================================================

(defmethod! run-py ((code python) &key (cabecario nil) (remove-tmpfile t))
:initvals '(nil)
:indoc '("Python Class" "Here you connect the box py-code with all the modules that will be used, global variables, functions, etc." "Remove the script after execution.") 
:icon 'py-f
:doc "This object will run python scripts inside the py and py-code special-boxes. "

(stop-python-print-server)
(if om::*vscode-is-open?* 
    (progn 
            (om::om-message-dialog "It is good practice to close the VScode first, run the python code without close VScode could result in errors!")   ;; MAKE A DIALOG
            ; (om::abort-eval)
            ))

; ================= PYTHON PRINT ON OM ==========================================
(if (not om_py-threading_work) 
(start-python-print-server))
; ================= PYTHON PRINT ON OM ==========================================

(let* (
      (python-code (code (py-append-code cabecario code)))
      (python-name (om::string+ "py-code-temp-" (write-to-string (om-random 10000 999999)) ".py"))
      (save-python-code (om::save-as-text python-code (om::tmpfile python-name :subdirs "om-py")))
      (prepare-cmd-code (py-list->string (list (namestring save-python-code))))
      (where-i-am-running 
                              #+mac (om::string+ *activate-virtual-enviroment* " && python3 ")
                              #+windows (om::string+ *activate-virtual-enviroment* " && python ")
                              #+linux (om::string+ *activate-virtual-enviroment* " && python3 ")))
      (oa::om-command-line (om::string+ where-i-am-running prepare-cmd-code) t)
      (let* (
            (data (om::make-value-from-model 'textbuffer (probe-file (merge-pathnames (user-homedir-pathname) "py_values.txt")) nil)))
            (mp:process-run-function "del-py-code" () (lambda (x) (if remove-tmpfile (clear-the-file x))) (om::tmpfile python-name :subdirs "om-py"))
            (mp:process-run-function "del-data-code" () (lambda (x) (if remove-tmpfile (clear-the-file x))) (merge-pathnames (user-homedir-pathname) "py_values.txt"))
            (stop-python-print-server)
             
            (read_from_python (if   (null data)        
                                            nil
                                           (om::get-slot-val (progn (setf (om::reader data) :lines-cols) data) "CONTENTS"))))))
                     
;; ========================

(defmethod! py-add-var ((function function) &rest rest)
:initvals '("Py-code function in lambda mode" "all the variables used.")
:indoc '("run py") 
:icon 'py-f
:doc ""

(let* (
      (check-all-rest (loop :for type :in rest :collect type))
      (py-var (apply 'mapcar function check-all-rest)))
      (om::make-value 'python (list (list :code (concatstring (mapcar (lambda (x) (code x)) py-var)))))))

;; ========================

(defmethod! py-concat-code ((codes list))
:initvals '("It concat a list of python classes.")
:indoc '("run py") 
:icon 'py-f
:doc ""

(om::make-value 'om-py::python (list (list :code (concatString (loop :for code :in codes :collect (if (null code)
                                                                                                      nil 
                                                                                                    (case (type-of code) 
                                                                                                          ('|om-python|::py-externals-mod (om::string+ (modules code) (string #\Newline)))                                                                                           ('|om-python|::python (om::string+ (code code) (string #\Newline)))))))))))
;; ========================

(defmethod! py-append-code (&rest rest)
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc "It works like x-append with key inputs for python classes."

(py-concat-code (flat (om::x-append rest nil nil))))

;; ========================

(defmethod! py-remove-ext-modules ((string string))
:initvals '("The name of external module to be removed.")
:indoc '("run py") 
:icon 'py-f
:doc "This object will remove the external modules from the python environment."

(om-cmd-line (format nil "~d && pip uninstall -y ~d" om-py::*activate-virtual-enviroment*  string)))


;; ========================

(defmethod! py-add-ext-modules (&key (import nil) (from_import nil) (import* nil))
:initvals '("math" ("math" "sum") "math")
:indoc '("import YOURMODULE" "from YOURMODULE import YOURFUNCTION" "import YOURMODULE*") 
:icon 'py-f
:doc "This object will add external modules to the python environment."

;; COLOCAR UM MODO DE SEMPRE RODAR O PIP UPGRADE PIP

(if   
      (or (= 2 (list-depth from_import)) (null from_import))
            from_import
            (progn
                  (om::om-message-dialog (format nil "The from_import key seems to be inappropriately formatted!"))
                  (om::abort-eval)))

(let* (
      (import-modules (om::x-append 
                                    (om::list! import)
                                    (mapcar (lambda (x) (car x)) from_import)
                                    (om::list! import*)))
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
      (check-the-modules (om-py::run-py (om::make-value 'python (list (list :code all_code))))))                
      (loop :for not_installed :in (om::list! check-the-modules)
            :do 
                  (let* (
                              (visual-message (pip-install not_installed))
                              (install_modules 
                                    (case (car visual-message)
                                          (1 (om::om-cmd-line 
                                                      #+mac (format nil "~d && python3 -m pip install ~d" *activate-virtual-enviroment* not_installed)
                                                      #+windows (format nil "~d && pip install ~d" *activate-virtual-enviroment*  not_installed)
                                                      #+linux (format nil "~d && pip3 install ~d" *activate-virtual-enviroment*  not_installed)))
                                          (0 nil)
                                          (nil (om::abort-eval)))))
                                    (if 
                                          (equal install_modules 1) 
                                          (progn 
                                                      (om::om-message-dialog (format nil "The module ~d was not found, check the spelling!" not_installed))
                                                      (om::abort-eval)))))
      (let* (
            (format-import (loop :for modules :in (om::list! import) :collect (format nil "
import ~d" modules)))
            (format-from_import (loop for modules :in (om::list! from_import) :collect (format nil "
from ~d import ~d" (car modules) (second modules))))
            (format_import* (loop for modules :in (om::list! import*) :collect (format nil "
from ~d import *" modules)))
            (all-modules 
                  (concatstring (om::x-append 
"
from om_py import to_om" format-import format-from_import format_import*))))
      (om::make-value 'py-externals-mod (list (list :modules all-modules))))))

;==================================
(defmethod! py-open-script ((python string))
(py-open-script (probe-file python)))

; =================================

(defmethod! py-open-script ((python pathname))
:initvals '(nil)
:indoc '("The pathname of the python script to be opened.") 
:icon 'py-f
:doc "This object will open python scripts in the VsCode editor (When it is installed)."

(oa::om-command-line (om::string+ "code " (namestring python) " -w") nil))

;==================================

(defmethod! py->text ((python python))
:initvals '("Some python class.")
:indoc '("Python class") 
:icon 'py-f
:doc "It convert python class to textbuffer class so see the code before running it."

(om::make-value 'om::textbuffer (list (list :contents (code python)))))

;==================================

(defmethod! text->py ((python string))
:initvals '("Some python class.")
:indoc '("Python class") 
:icon 'py-f
:doc "It convert string to a python class to make possible run it with the run-py object."


(om::make-value 'python (list (list :code python))))

;================================== OM-PY Developers ============================
(defun read_python_script (filename)
    (with-open-file (stream filename)
        (loop   :for line := (read-line stream nil)
                :while line
                :collect (om::string+ line (string #\NewLine)))))

; ------------------------------------------------------------
(defun lispVar2PyVar(listOfNames listOfValues)
    (loop :for variable_name :in listOfNames
          :for value :in listOfValues
          :collect (format nil "~a=~a~d" (string variable_name) (format2python-v3 value) (string #\NewLine))))


; ------------------------------------------------------------
(defun run-py-script (filename listOfVariables listOfValues &key (thread nil))

(if (not (equal (length listOfVariables) (length listOfValues)))
    (om::om-message-dialog "Developer Warning: The number of Variables and Values are different"))

    (let* (
            (readScript (read_python_script filename))
            (pyVar (lispVar2PyVar listOfVariables listOfValues))
            (pyScript (om-py::concatstring (om::x-append pyVar readScript)))
            (om-pyClass (om::make-value 'python (list (list :code pyScript)))))
            (if thread
                  (mp:process-run-function "Python" ()
                        (lambda () (om-py::run-py om-pyClass)))
                  (om-py::run-py om-pyClass))))

; ------------------------------------------------------------
(defun find-library-PyScripts (libname scriptname)
      (let* (
            (scriptPath (merge-pathnames (format nil "resources/python/~d" scriptname)  (om::mypathname (om::find-library libname)))))
            (if (probe-file scriptPath) 
                        scriptPath 
                        (progn 
                              (om::om-message-dialog (format nil "The script '~d' was not found in the library '~d'" scriptname libname)) 
                              (om::abort-eval)))))


;================================== CHECK OM-PY UPDATE ============================

(defparameter *this-version* 0.3)

(ignore-errors 
      (mp:process-run-function "Check for om-py updates!" () 
            (lambda ()
                  (if (and (om::get-pref-value :externals :check-updates) (not (om::loaded? (om::find-library "OM-py"))))
                        (let* (
                              (tmpfile (om::tmpfile "om-py-version.txt"))
                              (cmd-command
                                    #+windows(oa::om-command-line (format nil "curl https://raw.githubusercontent.com/charlesneimog/om-py/master/resources/version.lisp --ssl-no-revoke --output  ~d" (namestring tmpfile)) nil)
                                    #+mac(oa::om-command-line (format nil "curl https://raw.githubusercontent.com/charlesneimog/om-py/master/resources/version.lisp -L --output ~d" (namestring tmpfile)) nil)
                                    #+linux (oa::om-command-line (format nil "wget https://raw.githubusercontent.com/charlesneimog/om-py/master/resources/version.lisp --O ~d" (namestring tmpfile)) nil)))
                              
                              (if (not (equal cmd-command 0)) 
                                    (setf *actual-version* 0)                            
                                    (eval (read-from-string (car (uiop:read-file-lines tmpfile)))))    
                              
                              (if (> *actual-version* *this-version*)
                                    (let* (
                                    
                                          (update? (om::om-y-or-n-dialog (format nil "The library om-py has been UPDATED to version ~d. Want to update now?" (write-to-string *actual-version*)))))   
                                          (if update?
                                                (hqn-web:browse "https://github.com/charlesneimog/om-py/releases/latest")))
                                                      (alexandria::delete-file tmpfile)))))))
                              
; =====================================

