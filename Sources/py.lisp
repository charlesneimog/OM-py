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

(in-package :om)

;;; ==========================================================================

(defclass OMPYFunction (OMProgrammingObject)
  ((text :initarg :text :initform "" :accessor text)
   (error-flag :initform nil :accessor error-flag)))

;; ============================= PY Special Boxes ===========================

(defmethod get-object-type-name ((self OMPYFunction)) "Code")

;; ======

(defmethod default-compiled-gensym  ((self OMPYFunction)) (gensym "pyfun-"))

;; ======

(defclass OMPyFunctionInternal (OMPYFunction) ()
  (:default-initargs :icon :py-f)
  (:metaclass om::omstandardclass))

;; ======

(defparameter *default-py-function-text*

  '(";;; edit a valid python code, It will just run it."
    ";;; changing the variables you want to use "
    ";;; inside om-sharp to {til}d."
    ";;; The name 'LIST' CANNOT be used as a variable name."
    "(py_var () 
\"
from om_py.python_to_om import to_om
sum = 2 + 2 
to_om(sum) # If you want to use something inside OM, you need to print it.

\"  )"))

;; ======

(defmethod omNG-make-special-box ((reference (eql 'py-code)) pos &optional init-args)
  (omNG-make-new-boxcall
   (make-instance 'OMPyFunctionInternal
                  :name (if init-args (format nil "~A" (car (list! init-args))) "py-code")
                  :text *default-py-function-text*)
          pos init-args))

;; ======

(defmethod decapsulable ((self OMPYFunction)) nil)

;; ======

(defmethod update-py-fun ((self OMPYFunction))
  (compile-patch self)
  (loop :for item :in (references-to self) do
        (update-from-reference item)))

;; ======

(defmethod copy-contents ((from OMPYFunction) (to OMPYFunction))
  (setf (text to) (text from)) to)

;; ======

(defmethod compile-patch ((self OMPYFunction))
  "Compilation of a py function"
    (setf (error-flag self) nil)
    (let* (
      (lambda-expression (read-from-string (reduce #'(lambda (s1 s2) (concatenate 'string s1 (string #\Newline) s2)) (text self)) nil))
      (var (car (cdr lambda-expression)))
      (python-var (mapcar (lambda (y) `(om::string+ ,y)) (mapcar (lambda (x) (string+ (write-to-string x) " " "= ")) var)))
      (format2python (mapcar (lambda (x) `(om-py::format2python-v3 ,x)) var))
      (lisp-var2py-var (mapcar (lambda (x y) (list `(,@x ,y (string #\Newline)))) python-var format2python))
      (python-string (list (second (cdr lambda-expression))))
      (code (om::flat `(,@lisp-var2py-var ,python-string) 1))
      (add-append (list `(x-append ,@code nil)))
      (py-code (list `(om::make-value (quote om-py::python) (list (list :code (om-py::concatstring ,@add-append ))))))
      (function-def
            (if (and lambda-expression (python-expression-p lambda-expression))
                  (progn (setf (compiled? self) t)
                          `(defun ,(intern (string (compiled-fun-name self)) :om) 
                                              ,var  
                                              ,@py-code))                                                       
                  (progn (om-beep-msg "ERROR ON PY FORMAT!!")
                        (setf (error-flag self) t)
                       `(defun ,(intern (string (compiled-fun-name self)) :om) () nil)))))
(compile (eval function-def))))

;;;===================
;;; py FUNCTION BOX
;;;===================

(defmethod special-box-p ((name (eql 'py-code))) t)

;; ======

(defclass OMBoxpy (OMBoxAbstraction) ())

;; ======

(defmethod get-box-class ((self OMpyFunction)) 'OMBoxpy)

;; ======

(defmethod draw-patch-icon :after ((self OMBoxpy) &optional (offset-x 0) (offset-y 0))
  (when (error-flag (reference self))
    (om-with-fg-color (om-def-color :darkgreen)
      (om-with-font (om-make-font "Arial" 14 :style '(:bold))
                    (om-draw-string (+ offset-x 2) (+ offset-y (- (box-h self) 8)) "Error !!")))))

;; ======

(defmethod create-box-inputs ((self OMBoxpy))
  (compile-if-needed (reference self))
  (let ((fname (intern (string (compiled-fun-name (reference self))) :om)))
    (when (fboundp fname)
      (let ((args (function-arg-list fname)))
        (loop :for a :in args collect
              (make-instance 'box-input :name (string a)
                             :box self :reference nil)))
      )))

;; ======

(defmethod create-box-outputs ((self OMBoxpy))
  (list
   (make-instance 'box-output :reference nil
                  :name "out"
                  :box self)))

;; ======

(defmethod update-from-reference ((self OMBoxpy))

  (let ((new-inputs (loop :for i :in (create-box-inputs self)
                          :for ni from 0 collect
                          (if (nth ni (inputs self))
                              (let ((ci (copy-io (nth ni (inputs self))))) ;;keep connections, reactivity etc.
                                (setf (name ci) (name i)) ;; just get the new name
                                ci)
                            i)))
        (new-outputs (loop :for o :in (create-box-outputs self)
                           :for no :from 0 collect
                           (if (nth no (outputs self))
                               (copy-io (nth no (outputs self)))
                             o))))

;; ======

    ;;; remove orphan connections
    (loop :for in :in (nthcdr (length new-inputs) (inputs self)) do
          (mapc #'(lambda (c) (omng-remove-element (container self) c)) (connections in)))

    (set-box-inputs self new-inputs)
    (set-box-outputs self new-outputs)
    (set-frame-areas (frame self))
    (om-invalidate-view (frame self))
    t))

;; ======

(defmethod display-modes-for-object ((self OMpyFunction)) '(:hidden :mini-view :value))

;; ======

(defmethod draw-mini-view ((self OMpyFunction) box x y w h &optional time)
  (let ((di 12))
    (om-with-font
     (om-def-font :font1 :size 10)
     (loop :for line :in (text self)
           :for i = (+ y 18) then (+ i di)
           while (< i (- h 18)) do
           (om-draw-string (+ x 12) i line)))))

;;;===================
;;; EDITOR
;;;===================

(defclass py-function-editor (OMDocumentEditor) ())

(defmethod object-has-editor ((self OMpyFunction)) t)
(defmethod get-editor-class ((self OMpyFunction)) 'py-function-editor)

;;; nothing, e.g. to close when the editor is closed
(defmethod delete-internal-elements ((self OMpyFunction)) nil)

;;; maybe interesting to make this inherit from OMEditorWindow..

(defclass py-function-editor-window (om-lisp::om-text-editor-window)
  ((editor :initarg :editor :initform nil :accessor editor)))

(defmethod window-name-from-object ((self OMpyFunctionInternal))
  (format nil "~A  [internal py function]" (name self)))

(defmethod om-lisp::type-filter-for-text-editor ((self py-function-editor-window))
  '("py function" "*.py"))

;;; this will disable the default save/persistent behaviours of the text editor
;;; these will be handled following the model of OMPatch
(defmethod om-lisp::save-operation-enabled ((self py-function-editor-window)) nil)

(defmethod open-editor-window ((self py-function-editor))
  (if (and (window self) (om-window-open-p (window self)))
      (om-select-window (window self))
    (let* ((pyf (object self))
           (edwin (om-lisp::om-open-text-editor
                   :contents (text pyf)
                   :lisp t
                   :class 'py-function-editor-window
                   :title (window-name-from-object pyf)
                   :x (and (window-pos pyf) (om-point-x (window-pos pyf)))
                   :y (and (window-pos pyf) (om-point-y (window-pos pyf)))
                   :w (and (window-size pyf) (om-point-x (window-size pyf)))
                   :h (and (window-size pyf) (om-point-y (window-size pyf)))
                   )))
      (setf (editor edwin) self)
      (setf (window self) edwin)
      (om-lisp::text-edit-window-activate-callback edwin t) ;; will (re)set the menus with the editor in place
      edwin)))

(defmethod om-lisp::text-editor-window-menus ((self py-function-editor-window))
  (om-menu-items (editor self)))

(defmethod om-lisp::om-text-editor-modified ((self py-function-editor-window))
  (touch (object (editor self)))
  (setf (text (object (editor self)))
        (om-lisp::om-get-text-editor-text self))
  (report-modifications (editor self))
  (call-next-method))

(defmethod om-lisp::update-window-title ((self py-function-editor-window) &optional (modified nil modified-supplied-p))
  (om-lisp::om-text-editor-window-set-title self (window-name-from-object (object (editor self)))))

(defmethod om-lisp::om-text-editor-check-before-close ((self py-function-editor-window))
  (ask-save-before-close (object (editor self))))

(defmethod om-lisp::om-text-editor-resized ((win py-function-editor-window) w h)
  (when (editor win)
    (setf (window-size (object (editor win))) (omp w h))))

(defmethod om-lisp::om-text-editor-moved ((win py-function-editor-window) x y)
  (when (editor win)
    (setf (window-pos (object (editor win))) (omp x y))))

;;; update-py-fun at closing the window
(defmethod om-lisp::om-text-editor-destroy-callback ((win py-function-editor-window))
  (let ((ed (editor win)))
    (editor-close ed)
    (update-py-fun (object ed))
    (setf (window ed) nil)
    (setf (g-components ed) nil)
    (unless (references-to (object ed))
      (unregister-document (object ed)))
    (call-next-method)))

;;; update-py-fun at loosing focus
(defmethod om-lisp::om-text-editor-activate-callback ((win py-function-editor-window) activate)
  (when (editor win)
    (when (equal activate nil)
      (update-py-fun (object (editor win))))
    ))

;;; called from menu
(defmethod copy-command ((self py-function-editor))
  #'(lambda () (om-lisp::text-edit-copy (window self))))

(defmethod cut-command ((self py-function-editor))
  #'(lambda () (om-lisp::text-edit-cut (window self))))

(defmethod paste-command ((self py-function-editor))
  #'(lambda () (om-lisp::text-edit-paste (window self))))

(defmethod select-all-command ((self py-function-editor))
  #'(lambda () (om-lisp::text-select-all (window self))))

(defmethod undo-command ((self py-function-editor))
  #'(lambda () (om-lisp::text-edit-undo (window self))))

(defmethod font-command ((self py-function-editor))
  #'(lambda () (om-lisp::change-text-edit-font (window self))))




;; ===============================================================
;; ================ Python Code Editor Inside OM =================
;; ================ Python Code Editor Inside OM =================
;; ================ Python Code Editor Inside OM =================
;; ===============================================================

(defclass run-py-f (OMProgrammingObject)
  ((text :initarg :text :initform "" :accessor text)
   (error-flag :initform nil :accessor error-flag)))

;; ======
(defmethod get-object-type-name ((self run-py-f)) "run")

;; ======
(defmethod default-compiled-gensym  ((self run-py-f)) (gensym "py-run-"))

;; ======
(defclass run-py-f-internal (run-py-f) ()
  (:default-initargs :icon :py-f)
  (:metaclass om::omstandardclass))

;; ======

(defparameter *default-py-run-function-text*

  '(";;; edit a valid python code, It will just run it."
    ";;; changing the variables you want to use "
    ";;; inside om-sharp to {til}d."
    ";;; The name 'LIST' CANNOT be used as a variable name."
    "(py_var () 
\"
from om_py.python_to_om import to_om

list_of_numbers = []

for x in range(10):
    list_of_numbers.append(x)

to_om(list_of_numbers)

\"  )"))

;; ======


;; ==================================== READ PYTHON SCRIPT
(defun read-python-script (path)

(let* (
       (get-var-in-py (om::get-python-var-from-script (om-py::read-python-script-lines path)))
       (remove-all-non-lisp-text  
              (let* (
                     (python-script-lines (om-py::read-python-script-lines path))
                     (remove-om2py-adaptation (om::remove-om2py-adaptation python-script-lines))
                     (remove-notice-2 (om-py::remove-py-var remove-om2py-adaptation  '("# ======================= Add OM Variables ABOVE this Line ========================")))
                     (remove-extra-line (if (equal (car remove-notice-2) "") (cdr remove-notice-2) remove-notice-2)))
                     (if (equal (car (last remove-notice-2)) "") (om::first-n remove-notice-2 (- (length remove-notice-2) 1)) remove-notice-2)))   
       
       (read-edited-code 
              (om-py::py-list->string (list 
                     (om-py::concatstring (mapcar (lambda (x) (om::string+ x (string #\Newline))) remove-all-non-lisp-text)))))
       
       (get-var-in-py-formatted (om-py::concatstring (om::flat (mapcar (lambda (x) (x-append x " ")) get-var-in-py))))
       (variables-in-lisp   (if    (null get-var-in-py)
                                   (om::x-append (om::string+ "(py_var " (write-to-string variables)) read-edited-code ")")
                                   (om::x-append (om::string+ "(py_var ("  get-var-in-py-formatted ")" (string #\Newline)) read-edited-code ")"))))
      variables-in-lisp)) 
        
;; ==============================================================================

(defmethod omNG-make-special-box ((reference (eql 'py)) pos &optional init-args)
  
  (let* (
        (py-script-name (if (null (car (list! init-args))) " new-py-script " (write-to-string (car (list! init-args)))))
        (adapt-window (if (> (length py-script-name) 14)
                          py-script-name
                          (let* (
                                (ideal-length (round (/ (- 14 (length py-script-name))) 2))
                                (length-even-number (if (oddp ideal-length) (+ ideal-length 1) ideal-length))
                                (length-of-name (if (< length-even-number 1) 2 length-even-number))
                                (backspace (reduce (lambda (x y) (concatenate 'string x y)) (om::repeat-n " " length-of-name))))
                                (om::string+ backspace py-script-name backspace))))
        (script-text (let* (
                            (script-pathname (merge-pathnames (om::string+ py-script-name ".py") (get-pref-value :externals :py-scripts)))
                            (file-exits? (probe-file script-pathname)))
                                (if file-exits?
                                      (read-python-script script-pathname)
                                      *default-py-run-function-text*))))
        
(omNG-make-new-boxcall (make-instance 'run-py-f-internal :name adapt-window :text script-text) pos (om::list! adapt-window))))

;; ======================================================
;; ======================================================


(defmethod decapsulable ((self run-py-f)) nil)

;; ======

(defmethod update-py-fun ((self run-py-f))
  (compile-patch self)
  (loop for item in (references-to self) do
        (update-from-reference item)))

;; ======

(defmethod copy-contents ((from run-py-f) (to run-py-f))
  (setf (text to) (text from)) to)

;; ======

(defun python-expression-p (form)
  (and (consp form)
       (eq (%car form) 'py_var)
       (consp (%cdr form))
       (listp (%cadr form))))

;; ======

(defmethod compile-patch ((self run-py-f))
  "Compilation of a py function"
    (setf (error-flag self) nil)
    (let* (
      (lambda-expression (read-from-string (reduce #'(lambda (s1 s2) (concatenate 'string s1 (string #\Newline) s2)) (text self)) nil))
      (var (car (cdr lambda-expression)))
      (python-var (mapcar (lambda (y) `(om::string+ ,y)) (mapcar (lambda (x) (string+ (write-to-string x) " " "= ")) var)))
      (format2python (mapcar (lambda (x) `(om-py::format2python-v3 ,x)) var))
      (lisp-var2py-var (mapcar (lambda (x y) (list `(,@x ,y (string #\Newline)))) python-var format2python))
      (python-string (list (second (cdr lambda-expression))))
      (code (om::flat `(,@lisp-var2py-var ,python-string) 1))
      (add-append (list `(x-append ,@code nil)))
      (py-code (list `(om-py::run-py (om::make-value (quote om-py::python) (list (list :code (om-py::concatstring ,@add-append )))))))
      (function-def
            (if (and lambda-expression (python-expression-p lambda-expression))
                  (progn (setf (compiled? self) t)
                          `(defun ,(intern (string (compiled-fun-name self)) :om) 
                                              ,var  
                                              ,@py-code))                                                       
                  (progn (om-beep-msg "ERROR ON PY FORMAT!!")
                        (setf (error-flag self) t)
                       `(defun ,(intern (string (compiled-fun-name self)) :om) () nil)))))
(compile (eval function-def))))

;;; ==============================
;;; Externalize File
;;; ==============================

;============================================================================
; Py Function as external file
;============================================================================

(defclass OMpyFunctionFile (OMPersistantObject run-py-f) ()
  (:default-initargs :icon :py-script)
  (:metaclass omstandardclass))

(add-om-doctype :pyfun "py" "Python Script")

(defmethod object-doctype ((self run-py-f)) :textfun)

(defmethod type-check ((type (eql :textfun)) obj)
  (let ((fun (ensure-type obj 'run-py-f)))
    (when fun
      (change-class fun 'OMpyFunctionFile)
      (setf (icon fun) :py-script)) ;;; ICONE QUANDO É EXTERNALIZADO
    fun))


; For conversions
(defmethod internalized-type ((self OMpyFunctionFile)) 'run-py-f-internal)
(defmethod externalized-type ((self run-py-f)) 'OMpyFunctionFile)
(defmethod externalized-icon ((self run-py-f)) :py-script)

(defmethod make-new-om-doc ((type (eql :pyfun)) name)
  (make-instance 'OMpyFunctionFile
                 :name name
                 :text *default-lisp-function-text*))

(defmethod save-document ((self OMpyFunctionFile))
  (call-next-method)
  (update-py-fun self))

(defmethod omng-save-relative ((self OMpyFunctionFile) ref-path)
  `(:textfun-from-file
    ,(if (mypathname self)
         (omng-save (om::om-print (relative-pathname (mypathname self) ref-path) "test"))
       (omng-save (om::om-print (pathname (name self))) "test"))))


(defmethod om-load-from-id ((id (eql :textfun-from-file)) data)
  (let* ((path (omng-load (car data)))
         (checked-path (and (pathname-directory path)  ;; normal case
                            (check-path-using-search-path path)))
         (pyfun

              (if checked-path
                  (load-doc-from-file checked-path :textfun)
                  (let ((registered-entry (find (pathname-name path) *open-documents*
                                          :test 'string-equal :key #'(lambda (entry) (name (doc-entry-doc entry))))))
                  (om::om-print registered-entry "test")
                  (when registered-entry
                      (doc-entry-doc registered-entry))) )))

    (unless pyfun
      (om-beep-msg "PY-FUN FILE NOT FOUND: ~S !" path)
      (setf pyfun (make-instance 'OMpyFunctionFile :name (pathname-name path)))
      (setf (mypathname pyfun) path))

    pyfun))



;;;===================
;;; py FUNCTION BOX
;;;===================

(defmethod special-box-p ((name (eql 'py))) t)

;; ======

(defclass OMBox-run-py (OMBoxAbstraction) ())

;; ======

(defmethod get-box-class ((self run-py-f)) 'OMBox-run-py)

;; ======

(defmethod draw-patch-icon :after ((self OMBox-run-py) &optional (offset-x 0) (offset-y 0))
  (when (error-flag (reference self))
    (om-with-fg-color (om-def-color :darkgreen)
      (om-with-font (om-make-font "Arial" 14 :style '(:bold))
                    (om-draw-string (+ offset-x 2) (+ offset-y (- (box-h self) 12)) "Error !!")))))

;; ======

(defmethod create-box-inputs ((self OMBox-run-py))
  (compile-if-needed (reference self))
  (let ((fname (intern (string (compiled-fun-name (reference self))) :om)))
    (when (fboundp fname)
      (let ((args (function-arg-list fname)))
        (loop for a in args collect
              (make-instance 'box-input :name (string a)
                             :box self :reference nil))))))

;; ======

(defmethod create-box-outputs ((self OMBox-run-py))
  (list
   (make-instance 'box-output :reference nil
                  :name "out"
                  :box self)))

;; ======

(defmethod update-from-reference ((self OMBox-run-py))

  (let ((new-inputs (loop for i in (create-box-inputs self)
                          for ni from 0 collect
                          (if (nth ni (inputs self))
                              (let ((ci (copy-io (nth ni (inputs self))))) ;;keep connections, reactivity etc.
                                (setf (name ci) (name i)) ;; just get the new name
                                ci)
                            i)))
        (new-outputs (loop for o in (create-box-outputs self)
                           for no from 0 collect
                           (if (nth no (outputs self))
                               (copy-io (nth no (outputs self)))
                             o))))

;; ======

    ;;; remove orphan connections
    (loop for in in (nthcdr (length new-inputs) (inputs self)) do
          (mapc #'(lambda (c) (omng-remove-element (container self) c)) (connections in)))

    (set-box-inputs self new-inputs)
    (set-box-outputs self new-outputs)
    (set-frame-areas (frame self))
    (om-invalidate-view (frame self))
    t))

;; ======

(defmethod display-modes-for-object ((self run-py-f)) '(:hidden :mini-view :value))

;; ======

(defmethod draw-mini-view ((self run-py-f) box x y w h &optional time)
  (let ((di 12))
    (om-with-font
     (om-def-font :font1 :size 10)
     (loop for line in (text self)
           for i = (+ y 18) then (+ i di)
           while (< i (- h 18)) do
           (om-draw-string (+ x 12) i line)))))

;;;===================
;;; EDITOR
;;;===================

(defclass run-py-function-editor (OMDocumentEditor) ())

(defmethod object-has-editor ((self run-py-f)) t)
(defmethod get-editor-class ((self run-py-f)) 'run-py-function-editor)

;;; nothing, e.g. to close when the editor is closed
(defmethod delete-internal-elements ((self run-py-f)) nil)

;;; maybe interesting to make this inherit from OMEditorWindow..

(defclass run-py-function-editor-window (om-lisp::om-text-editor-window)
  ((editor :initarg :editor :initform nil :accessor editor)))

(defmethod window-name-from-object ((self run-py-f-Internal))
  (format nil "~A  [internal py function]" (name self)))

(defmethod om-lisp::type-filter-for-text-editor ((self run-py-function-editor-window))
  '("py function" "*.py"))

;;; this will disable the default save/persistent behaviours of the text editor
;;; these will be handled following the model of OMPatch
(defmethod om-lisp::save-operation-enabled ((self run-py-function-editor-window)) nil)

(defmethod open-editor-window ((self run-py-function-editor))
  (if (and (window self) (om-window-open-p (window self)))
      (om-select-window (window self))
    (let* ((pyf (object self))
           (edwin (om-lisp::om-open-text-editor
                   :contents (text pyf)
                   :lisp t
                   :class 'run-py-function-editor-window
                   :title (window-name-from-object pyf)
                   :x (and (window-pos pyf) (om-point-x (window-pos pyf)))
                   :y (and (window-pos pyf) (om-point-y (window-pos pyf)))
                   :w (and (window-size pyf) (om-point-x (window-size pyf)))
                   :h (and (window-size pyf) (om-point-y (window-size pyf)))
                   )))
      (setf (editor edwin) self)
      (setf (window self) edwin)
      (om-lisp::text-edit-window-activate-callback edwin t) ;; will (re)set the menus with the editor in place
      edwin)))

(defmethod om-lisp::text-editor-window-menus ((self run-py-function-editor-window))
  (om-menu-items (editor self)))

(defmethod om-lisp::om-text-editor-modified ((self run-py-function-editor-window))
  (touch (object (editor self)))
  (setf (text (object (editor self)))
        (om-lisp::om-get-text-editor-text self))
  (report-modifications (editor self))
  (call-next-method))

(defmethod om-lisp::update-window-title ((self run-py-function-editor-window) &optional (modified nil modified-supplied-p))
  (om-lisp::om-text-editor-window-set-title self (window-name-from-object (object (editor self)))))

(defmethod om-lisp::om-text-editor-check-before-close ((self run-py-function-editor-window))
  (ask-save-before-close (object (editor self))))

(defmethod om-lisp::om-text-editor-resized ((win run-py-function-editor-window) w h)
  (when (editor win)
    (setf (window-size (object (editor win))) (omp w h))))

(defmethod om-lisp::om-text-editor-moved ((win run-py-function-editor-window) x y)
  (when (editor win)
    (setf (window-pos (object (editor win))) (omp x y))))

;;; update-py-fun at closing the window
(defmethod om-lisp::om-text-editor-destroy-callback ((win run-py-function-editor-window))
  (let ((ed (editor win)))
    (editor-close ed)
    (update-py-fun (object ed))
    (setf (window ed) nil)
    (setf (g-components ed) nil)
    (unless (references-to (object ed))
      (unregister-document (object ed)))
    (call-next-method)))

;;; update-py-fun at loosing focus
(defmethod om-lisp::om-text-editor-activate-callback ((win run-py-function-editor-window) activate)
  (when (editor win)
    (when (equal activate nil)
      (update-py-fun (object (editor win))))
    ))

;;; called from menu
(defmethod copy-command ((self run-py-function-editor))
  #'(lambda () (om-lisp::text-edit-copy (window self))))

(defmethod cut-command ((self run-py-function-editor))
  #'(lambda () (om-lisp::text-edit-cut (window self))))

(defmethod paste-command ((self run-py-function-editor))
  #'(lambda () (om-lisp::text-edit-paste (window self))))

(defmethod select-all-command ((self run-py-function-editor))
  #'(lambda () (om-lisp::text-select-all (window self))))

(defmethod undo-command ((self run-py-function-editor))
  #'(lambda () (om-lisp::text-edit-undo (window self))))

(defmethod font-command ((self run-py-function-editor))
  #'(lambda () (om-lisp::change-text-edit-font (window self))))

;; Add this in the menu


(ensure-directories-exist (tmpfile " " :subdirs "\om-py")) ;; Create om-py temp folder


    