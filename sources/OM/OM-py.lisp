
(in-package :om)

(defclass OMpythonPatch (OMPatch) 
  ((python-exp :initform nil :initarg :python-exp :accessor python-exp))
  (:icon 1997)
  (:documentation "The a patch written in python")
  (:metaclass omstandardclass))

;; =================================

(defclass OMpythonPatchAbs (OMpythonPatch ompatchabs) ()
  (:documentation "The a patch written in python")
  (:metaclass omstandardclass))

;; =================================

(defmethod obj-file-type ((self OMpythonPatch)) :python)
(defmethod obj-file-extension ((self OMpythonPatch)) "py")
(defmethod get-object-insp-name ((self OMpythonPatch)) "python Function")

;; =================================

(defmethod python-exp-p ((self OMpythonPatch)) t)

;; =================================
(defmethod get-python-str ((exp string)) (str-with-nl exp))
(defmethod get-python-str ((exp t)) (format nil "~A" exp))

;; =================================

(defmethod get-python-exp ((exp string)) (unless (string-equal "" exp) (read-from-string exp)))
(defmethod get-python-exp ((exp t)) exp)

;; =================================

(defun omNG-make-new-python-patch (name &optional (posi (om-make-point 0 0)))
 "Make an instance of patch."
    (let (
          (newpatch (make-instance 'OMpythonPatch :name name :icon 1997)))
          (set-icon-pos newpatch posi)
          newpatch))

;; =================================

(defun compile-python-patch-fun (patch)
  (print "I am the compile-python-patch-fun")
  

  
  
  (if (get-python-exp (python-exp patch))
      (eval `(defun ,(intern (string (code patch)) :om)
                    ,.(cdr (get-python-exp (python-exp patch)))))
    (eval `(defun ,(intern (string (code patch)) :om) () nil))))

;; =================================

(defmethod compile-patch ((self OMpythonPatch)) 
  "Generation of python code from the graphic boxes."
  (unless (compiled? self)
    (handler-bind 
        ((error #'(lambda (err)
                    (capi::display-message "An error of type ~a occurred: ~a" (type-of err) (format nil "~A" err))
                    (abort err))))
      (compile-python-patch-fun self)
      (setf (compiled? self) t))))

;; =================================

(defmethod load-abstraction-attributes ((self ompythonpatch) currentpersistent)
  (call-next-method) ;;; ompatch
  (setf (python-exp self) (python-exp currentpersistent))
  (when (python-exp self) (compile-python-patch-fun self)))

;; =================================

(defun om-load-python-patch (name version expression)
   (let ((newpatch (omNG-make-new-python-patch name)))
     (setf (omversion newpatch) version)
     (setf (python-exp newpatch) (get-python-str expression))
     newpatch))

;; =================================

(defun om-load-python-abspatch (name version expression)
   (let ((newpatch (make-instance 'OMpythonPatchAbs :name name :icon 1997)))
     (setf (omversion newpatch) version)
     (setf (python-exp newpatch) (get-python-str expression))
     (compile-python-patch-fun newpatch)
     newpatch))

;; =================================

(defmethod get-patch-inputs ((self OMpythonPatch))
  (unless (compiled? self)
    (compile-python-patch-fun self))
  (let* ((args (arglist (intern (string (code self)) :om)))
         (numins (min-inp-number-from-arglist args)) 
         (i -1))
    (print (format nil "numins = ~A" numins))
    (mapcar #'(lambda (name) 
                (make-instance 'omin
                               :indice (incf i)
                               :name (print (string name)))) 
            (subseq args 0 numins))))
     
;; =================================

(defmethod get-patch-outputs ((self OMpythonPatch))
  (list (make-instance 'omout
                       :name "python function output"
                       :indice 0)))

;; =================================

(defmethod om-save ((self OMpythonPatch) &optional (values? nil))
  `(setf *om-current-persistent* 
         (om-load-python-patch ,(name self) ,*om-version* ,(str-without-nl (python-exp self)))))

;; =================================

(defmethod omNG-copy ((self OMpythonPatch))
`(let ((copy ,(call-next-method)))
     (setf (python-exp copy) (python-exp ,self))
     (compile-python-patch-fun copy)
     copy))

;; =================================

(defmethod om-save ((self OMpythonPatchAbs) &optional (values? nil))
   "Generation of code to save 'self'."
   `(om-load-python-abspatch ,(name self) ,*om-version* ,(str-without-nl (python-exp self))))

;; =================================

(defmethod abs2patch ((self OMpythonPatchAbs) name pos)
   "Cons a new instance of 'OMPatch from the abstraction patch 'self'."
  (let ((newabs (omNG-make-new-python-patch name pos)))
    (setf (python-exp newabs) (python-exp self))
    (set-icon-pos newabs (get-icon-pos self)) 
    (setf (doc newabs) (doc self))
    newabs))

;; =================================

(defmethod patch2abs ((self OMpythonPatch))
   "Cons a new instance of 'OMPatchAbs from the patch 'self'."
    

   (let ((newabs (make-instance 'OMpythonPatchAbs :name (name self)  :icon 1997)))
     (setf (python-exp newabs) (python-exp self))
     (set-icon-pos newabs (get-icon-pos self))
     (setf (doc newabs) (doc self))
     newabs))

;; =================================

(defmethod OpenEditorframe ((self OMpythonPatch))
   "Open the patch editor, this method open too all persistantes objects referenced into the patch."
   
    (om-print self "OpenEditorframe :: ")
    (om::om-cmd-line "code ")
   
   
   
   (declare (special *om-current-persistent*)))