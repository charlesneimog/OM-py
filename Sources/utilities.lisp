(in-package :om)

;; ================= Some Functions =====================

(defun lisp-list_2_python-list (list)
      "Transform a list in lisp to a list in Python."
(let* (
      (list2string (mapcar (lambda (x) (ckn-int2string x)) list)))
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

;==================================== IMPORT NUMBERS ===================

(defconstant ckn-e (exp 1))

(defun euler-number ()
      (exp 1))

(defconstant ckn-i (sqrt -1))

(defun i-number ()
      ckn-i)


(defun pi-number ()
      pi)

;; SAMPLES AND DAW =================

(defun search-inside-some-folder (folder extension)                                                                         
      (let* (
            (thepath folder)
            (thefilelist (om-directory thepath 
                              :type extension
                              :directories t 
                              :files t 
                              :resolve-aliases nil 
                              :hidden-files nil))
            (more-folders? (mapcar (lambda (x) (if 
                                                      (system::directory-pathname-p x)
                                                      (search-inside-some-folder x extension)
                                                      x)) thefilelist)))
            more-folders?))

;==============================================================

(defun names-to-mix (in1)
(reduce (lambda (z y) (om::string+ z y))
          (flat (loop for x :in in1 :collect  
                      (flat (om::x-append " -v 1 " (list->string-fun (list (string+ (namestring x) " "))) " "))))))
                       ; (flat (om::x-append (list->string-fun (list (string+ (namestring x) " "))) " "))))))

;; =========================================

(om::defmethod* ckn-save-as-text ((self t) &optional (path "data") (type "txt"))
  :icon 908
  :initvals '(nil "data")
  :indoc '("data (list, BPF, or TextBuffer)" "a file location")
  :doc "Saves the data from <self> as a text file in <path>."
  (let ((file (cond
               ((null path) (om::om-choose-new-file-dialog :directory (def-save-directory) :types '("Text files" "*.txt" "All files" "*.*")))
               ((pathnamep path) path)
               ((stringp path) (if (pathname-directory path) (pathname (string+ path type)) (outfile path :type type))))))
    (if file
        (progn
          (with-open-file (out file :direction :output :if-does-not-exist :create :if-exists :supersede)
            (write-data self out))
          file)
      (om::om-abort))))

;; =========================================

(defmethod write-data ((self t) out)
  (format out "~A~%" self))

;==================================== 
(defun list->string-fun (ckn-list)
  (when ckn-list
    (concatenate 'string 
                 (write-to-string (car ckn-list)) (list->string-fun (cdr ckn-list)))))

;====================================

(defun list-dimensions (list depth)
  (loop :repeat depth
        :collect (length list)
        :do (setf list (car list))))

;=====================================

(defun list-to-array-fun (list depth)
  (make-array (list-dimensions list depth)
              :initial-contents list))

;=====================================

(defun array-to-list-fun (array)
  (let* ((dimensions (array-dimensions array))
         (depth      (1- (length dimensions)))
         (indices    (make-list (1+ depth) :initial-element 0)))
    (labels ((recurse (n)
               (loop :for j :below (nth n dimensions)
                     :do (setf (nth n indices) j)
                     :collect (if (= n depth)
                                (apply #'aref array indices)
                                (recurse (1+ n))))))
      (recurse 0))))

;=====================================

(defun by-N-fun (list n fun) 
  (loop for tail on list by (lambda (l) (nthcdr n l)) 
    :collect (funcall fun (subseq tail 0 (min (length tail) n)))))

;=====================================

(defun fft->phrase-fun (fft)
    (let* (   
        (fft-list (array-to-list-fun fft))
        (i-n (mapcar (lambda (x) (imagpart x)) fft-list))
        (r-n (mapcar (lambda (y) (realpart y)) fft-list)))
    (mapcar (lambda (x y) (atan x y)) i-n r-n)))

;=====================================

(defun fft->amplitude-fun (fft)
 (let* (   
       (fft-list (array-to-list-fun fft))
       (i-n (mapcar (lambda (x) (imagpart x)) fft-list)) ;; FILTRA A PARTE IMAGINÁRIA DO FFT
       (r-n (mapcar (lambda (y) (realpart y)) fft-list))) ;; FILTRA A PARTE REAL DO FFT
       
   (mapcar (lambda (x y) (sqrt (om::om+ (om::om^ x 2) (om::om^ y 2)))) i-n r-n)))

;======================================

(deftype complex-sample-array (&optional size)
  `(simple-array complex-sample (,size)))

;======================================
(defun energy (x)
  (let ((acc 0d0))
    (declare (type double-float acc))
    (map nil (lambda (x)
               (let ((r (realpart x))
                     (i (imagpart x)))
                 (incf acc (+ (* r r) (* i i))))) x) acc))

;======================================

(defvar *optimization-policy* '(optimize speed (safety 0))) ;; Otimização de processamento

;=====================================

(defun real-samplify (vec &optional (size (length vec)))
  (etypecase vec
    (real-sample-array vec)
    ((simple-array single-float 1)
     (map-into (make-array size
                           :element-type 'real-sample)
               (lambda (x)
                 (coerce x 'real-sample))
               vec))
    (sequence
     (map-into (make-array size
                           :element-type 'real-sample)
               (lambda (x)
                 (coerce x 'real-sample))
               vec))))

;=====================================

(deftype real-sample-array (&optional size)
  `(simple-array real-sample (,size)))

; ============================

(deftype real-sample ()
  'double-float)

; ============================

(defun lb (n)
  (integer-length (1- n)))

; ============================

(defun half-fun (in-array)
  (make-array (/ (length in-array) 2)
	      :element-type (array-element-type in-array)
	      :displaced-to in-array))

(compile 'half-fun)

;=====================================

(defun frobnicate (list)
  (loop with counter = 1
        for (prev next) on list
        when (and next (null prev))
          do (incf counter)
        when prev
          collect counter
        else
          collect prev))

(compile 'frobnicate)
;=====================================

(defun python-cmd-line (str)
  (oa::om-command-line str))

;========================= Multithreading with lispwork ====================

(defun ckn-mailbox-name (list-of-something)

(let* ()
      (loop :for chunks-number :in (arithm-ser 1 (length list-of-something) 1)
            :collect (list->string-fun (list 'mailbox- (om::om-random 100 999) chunks-number)))))

;========================= 

(defun ckn-mailbox-peek (mail-box)
(mapcar (lambda (x) (mp:mailbox-peek x)) mail-box))

;================================================

(defun ckn-make-mail-box (names-of-all-process)
(loop :for name-process :in names-of-all-process
      :collect (mp:make-mailbox :lock-name name-process)))

;===================================================================== Files control =====================================


(defun name-of-file (p)
  (let ((path (and p (pathname p))))
  (when (pathnamep path)
    (string+ (pathname-name path) 
             (if (and (pathname-type path) (stringp (pathname-type path)))
                 (string+ "." (pathname-type path)) 
               "")))))
               
;  ========================

(defun ckn-string-name (list-name)

(if (< (length list-name) 2)
    (car list-name)
(let*  (
    (action1 (om::string+ (first list-name) (second list-name)))
    (action2 (if 
                (>  (length (x-append action1 list-name)) 2)
                (x-append action1 (last-n list-name (- (length list-name) 2)))
                action1)))
    
    (if (< (length action2) 2)
            (first action2)
            (setf list-name (ckn-string-name action2))))))
            
(compile 'ckn-string-name)
;; ============

(defun ckn-int2string (int)
      "Number to string."
  (write-to-string int))

;; ============

(defun ckn-clear-temp-files ()

(let* ()
(print "clear temp files")
(ckn-cmd-line (string+ "powershell -command " 
                          (list->string-fun (list (string+ "del " 
                                            (list->string-fun (list (namestring (merge-pathnames "om-ckn/*.aif" (tmpfile ""))))))))))
(ckn-cmd-line (string+ "powershell -command " 
                          (list->string-fun (list (string+ "del " 
                                            (list->string-fun (list (namestring (merge-pathnames "om-ckn/*.wav" (tmpfile ""))))))))))))
;; ================================

(defun ckn-clear-the-file (thefile)


(mp:process-run-function (string+ "del-" (ckn-int2string (om-random 1 1000)))
                 () 
                 (lambda (x) (alexandria::delete-file thefile)) thefile))
 

;; ================================

(defun ckn-copy2outfile (x)
(let* ()
      (alexandria::copy-file x (outfile (name-of-file x)))
      (ckn-clear-temp-files)
      (outfile (name-of-file x))))


;; ================================

(defun ckn-copy2folder (x y)
(let* (
      (action1 (string+ "copy " (list->string-fun (list x)) " " (list->string-fun (list (namestring y))))))
      (ckn-cmd-line action1)
      (ckn-clear-temp-files)
      (merge-pathnames y (name-of-file x))))

;; ================================

(defun ckn-rename-file (x)
(let* (
      (action1 (string+ "copy " (list->string-fun (list x)) " " (list->string-fun (list (namestring (outfile "")))))))
      (ckn-cmd-line action1)
      (ckn-clear-temp-files)
      (outfile (name-of-file x))))

;; ================================

(defun ckn-list-to-string (lst)
    (format nil "~{~A ~}" lst))

;; ================================

(defmethod! ckn-temp-folder ((string string))
:initvals '(nil)
:indoc '("Temp folder") 
:icon '17359
:doc "Temp folder, not in OneDrive Folder."

(merge-pathnames (def-temp-folder) string))

;; ================================

(ensure-directories-exist (tmpfile " " :subdirs "\om-py"))

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

;; ================================== From py.lisp ==========================================
; =======================================================
; Functions to be used in the patches
; =======================================================

(defmethod! run-py ((code om2py) &optional (cabecario nil))
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc "With this object you can see the index parameters of some VST2 plugin."

(run-py (make-value 'to-om (list (list :py-inside-om (py-om code)))) cabecario))

;; ================================================

(defmethod! run-py ((code py-code) &optional (cabecario nil))
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc "With this object you can see the index parameters of some VST2 plugin."

(read_from_python (run-py (make-value 'to-om (list (list :py-inside-om (code code)))) cabecario)))

;; ========================

(defmethod! run-py ((code to-om) &optional (cabecario nil))
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc ""

(let* (
      (python-code (x-append cabecario " 

" (py-inside-om code)))
      (python-name (string+ "om-ckn-code" (ckn-int2string (om-random 10000 999999)) ".py"))
      (data-name (string+ "data" (ckn-int2string (om-random 10000 999999)) ".txt"))
      (save-python-code (om::save-as-text python-code (om::tmpfile python-name :subdirs "om-ckn")))
      (prepare-cmd-code (list->string-fun (list (namestring save-python-code)))))
      (om-cmd-line (string+ "python " prepare-cmd-code))
      (let* (
            (data (make-value-from-model 'textbuffer (merge-pathnames (user-homedir-pathname) "py_values.txt") nil)))
            (mp:process-run-function "del-py-code" () (lambda (x) (ckn-clear-the-file x)) (om::tmpfile python-name :subdirs "om-ckn"))
            (mp:process-run-function "del-data-code" () (lambda (x) (ckn-clear-the-file x)) (merge-pathnames (user-homedir-pathname) "py_values.txt"))
            (read_from_python (contents data)))))

;; ========================

(defmethod! py-add-var ((function function) &rest rest)
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc ""
(let* (
      (check-all-rest (loop :for type :in (om::list! rest) :collect (py-format2python type)))
      (py-var (apply 'mapcar function check-all-rest)))
      (make-value 'py-code (list (list :code (concatstring (mapcar (lambda (x) (py-om x)) py-var)))))))

;; ========================

(defmethod! bring-to-om ((code string))
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc ""

(make-value 'to-om (list (list :py-inside-om code))))

;; ========================

(defmethod! bring-to-om ((code list))
:initvals '(nil)
:indoc '("run py") 
:icon 'py-f
:doc ""

(make-value 'to-om (list (list :py-inside-om code))))

;; ========================

(defmethod! py->lisp ((result list))
:initvals '(nil)
:indoc '("result from py.") 
:icon 'py-f
:doc ""

(loop :for lista :in result
      :collect (remove nil (mapcar (lambda (y) (ignore-errors (parse-float y))) (string-to-list lista " ")))))

;; ========================

(defmethod! py-list ((result list))
:initvals '(nil)
:indoc '("result from py.") 
:icon 'py-f
:doc ""

(list (lisp-list_2_python-list result)))

;==================================

(defun format2python (type)
    (case (type-of type)
        (lispworks:simple-text-string (list type))
        (sound (let* (
                      (filepathname (namestring (car (if (not (file-pathname type)) 
                                                         (list (ckn-temp-sounds type (string+ "format-" (format nil "~7,'0D" (om-random 0 999999)) "-")))
                                                         (list (file-pathname type)))))))
                                    (string+ "r" "'" filepathname "'")))
        (fixnum (list (ckn-int2string type)))
        (float (ckn-int2string type))
        (cons (lisp->list-py-run (flat (mapcar (lambda (x) (list (format2python x))) type))))
        (single-float (list (ckn-int2string type)))
        (pathname   (list (namestring type)))))

;==================================

(defun py-format2python (type)
    (case (type-of type)
        (lispworks:simple-text-string (list type))
        (sound (let* (
                      (filepathname (namestring (car (if (not (file-pathname type)) 
                                                         (list (ckn-temp-sounds type (string+ "format-" (format nil "~7,'0D" (om-random 0 999999)) "-")))
                                                         (list (file-pathname type)))))))
                                    (string+ "r" "'" filepathname "'")))
        (fixnum (list (ckn-int2string type)))
        (float (ckn-int2string type))
        (cons (flat (mapcar (lambda (x) (list (format2python x))) type)))
        (single-float (list (ckn-int2string type)))
        (pathname   (list (namestring type)))))


; ====================== Add the functions in OM-Menu =======================

