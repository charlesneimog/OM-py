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

;; =========================

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

(defmethod draw-patch-icon :after ((self OMBoxpy) icon &optional (offset-x 0) (offset-y 0))
  (when (error-flag (reference self))
    (om-with-fg-color (om-def-color :dark-red)
      (om-with-font
       (om-make-font "Arial" 14 :style '(:bold))
       (om-draw-string (+ offset-x (/ (box-w self) 2) -30)
                       (+ offset-y 20)
                       "Error !!")))))

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
  (print "Quero Abrir o Editor")
  (print self)
  (print (text (object self)))
  (open-vscode (om::make-value 'OMPYFunction  (list (list :text (text (object self))))))
  
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

;; ========================================


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

