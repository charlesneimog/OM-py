(in-package :om)

;; ==========================================================================

(defparameter *vscode-is-open?* nil)

;; ==========================================================================

(defun get-python-var-from-script (x)

(remove nil (loop :for lines :in x 
      :while (not (equal lines "# ======================= Add OM Variables ABOVE this Line ========================"))
      :collect (if (or (equal lines "# ======================= Add OM Variables BELOW this Line ========================") (equal lines ""))
                   nil
                   (car (om::string-to-list lines))))))


;; ==========================================================================

(defun open-vscode (selected-boxes)

(let*  (
       (vs-code (read-from-string 
                     (reduce #'(lambda (s1 s2) 
                            (concatenate 'string s1 (string #\Newline) s2)) (text (reference (car (om::list! selected-boxes))))) nil))
       (var (car (cdr vs-code)))
       
       (python-var (mapcar (lambda (y) `(om::string+ ,y)) (mapcar (lambda (x) (string+ (write-to-string x) " " "= ")) var)))
       
       (input-values (mapcar (lambda (x) (omng-box-value x)) (inputs (car (om::list! selected-boxes))))) ;; get input values
       
       (separation1 (om::string+ "# ======================= Add OM Variables BELOW this Line ========================" (string #\Newline)))

       (separation2 (om::string+ "# ======================= Add OM Variables ABOVE this Line ========================" (string #\Newline)))
       
       (format2python (mapcar (lambda (x) (om-py::format2python-v3 x)) input-values))
       
       (lisp-var2py-var (mapcar (lambda (x y) `(,@x ,y (string #\Newline))) python-var (om::list! format2python)))
       
       (lisp-2-python-var (eval `(om-py::concatstring (om::x-append ,@lisp-var2py-var nil nil))))
       
       (path (om::save-as-text 
                     (om::string+ separation1 (string #\Newline) lisp-2-python-var (string #\Newline) separation2 (third vs-code))
                     (om::tmpfile (om::string+ "tmp-code-" (write-to-string (om::om-random 100 999)) ".py") :subdirs "om-py"))))
       
       (mp:process-run-function (string+ "VSCODE Running!") ;; Se não, a interface do OM trava
                                   () 
                                          (lambda () (vs-code-update-py-box path selected-boxes (second vs-code))))
       (setq *vscode-is-open?* t)))
    
; ==============================================================================

(defun remove-om2py-adaptation (x)
(set 'fim-das-variaves nil)
(loop :for lines :in x 
      :do (if (equal lines "# ======================= Add OM Variables ABOVE this Line ========================")
              (set 'fim-das-variaves t))
      :collect (if (eval 'fim-das-variaves) lines nil)))


;; =============================================================================

(defun vs-code-update-py-box (path selected-boxes variables)

(let* (
       
       (wait-edit-process (oa::om-command-line (om::string+ "code " (namestring path) " -w") nil))
       (get-var-in-py (om::get-python-var-from-script (om-py::read-python-script-lines path)))
       (remove-all-non-lisp-text  
              (let* (
                     (python-script-lines (om-py::read-python-script-lines path))
                     (remove-om2py-adaptation (remove-om2py-adaptation python-script-lines))
                     (remove-notice-2 (om-py::remove-py-var remove-om2py-adaptation  '("# ======================= Add OM Variables ABOVE this Line ========================")))
                     (remove-extra-line (if (equal (car remove-notice-2) "") (cdr remove-notice-2) remove-notice-2)))
                     (if (equal (car (last remove-notice-2)) "") (om::first-n remove-notice-2 (- (length remove-notice-2) 1)) remove-notice-2)))   
       
       (read-edited-code 
              (om-py::py-list->string (list 
                     (om-py::concatstring (mapcar (lambda (x) (om::string+ x (string #\Newline))) remove-all-non-lisp-text)))))
       
       (get-var-in-py-formatted (om-py::concatstring (om::flat (mapcar (lambda (x) (x-append x " ")) get-var-in-py))))
       (variables-in-lisp   (if    (null get-var-in-py)
                                   (x-append (om::string+ "(py_var " (write-to-string variables)) read-edited-code ")")
                                   (x-append (om::string+ "(py_var ("  get-var-in-py-formatted ")" (string #\Newline)) read-edited-code ")")))
       
       (from-box (if (equal (type-of (reference (car (om::list! selected-boxes)))) 'OMPyFunctionInternal)
                     (om::make-value 'OMPYFunction  (list (list :text variables-in-lisp)))
                     (om::make-value 'run-py-f  (list (list :text variables-in-lisp)))))
       (to-box (reference (car (om::list! selected-boxes)))))
       (copy-contents from-box to-box)
       (compile-patch to-box)
       (update-from-reference (car selected-boxes))
       (setq *vscode-is-open?* nil)
       (om-py::clear-the-file path)
       (om::om-print "Closing VScode!" "OM-Py")))

;; ========================================================================================

(defun list-search-py-contents (path)
  (and path
       (om-directory path
                     :files t :directories nil
                     :type '("py")
                     :recursive (get-pref-value :files :search-path-rec))))

;; ========================================================================================

(defun py-script-completion (patch string)
  (if (and *om-box-name-completion* (>= (length string) 1))
      (let* (
             (searchpath-strings (mapcar 'pathname-name
                                         (append (list-search-py-contents (get-pref-value :externals :py-scripts))))))
        (remove-if #'(lambda (str) (not (equal 0 (search string str :test 'string-equal)))) (append searchpath-strings)))))

;; ========================================================================================

(defmethod new-python-box-in-patch-editor ((self patch-editor-view) str position)
       (let* ((patch (find-persistant-container (object (editor self))))
              (new-box (omNG-make-special-box 'py position (list (read-from-string str)))))
              (when new-box
                     (store-current-state-for-undo (editor self))
                     (add-box-in-patch-editor new-box self))))

;; ========================================================================================
(defmethod enter-new-py-script ((self patch-editor-view) position &optional type)

  (let* ((patch (object (editor self)))
         (prompt "py script name")
         (completion-fun (if (equal type :py)
                             #'(lambda (string) (unless (string-equal string prompt)
                                                  (py-script-completion patch string)))
                           'box-name-completion))
         (verbose (print completion-fun))
         (textinput
              (om-make-di 'text-input-item
                     :text (print prompt)
                     :fg-color (om-def-color :gray)
                     :di-action #'(lambda (item)
                                     (let ((text (om-dialog-item-text item)))
                                       (om-end-text-edit item)
                                       (om-remove-subviews self item)
                                       (unless (string-equal text prompt)
                                                 (if (equal type :py)
                                                        (new-python-box-in-patch-editor self text position)
                                                        (let* ()
                                                               (om::om-print "I do not know what you want to do!" "om-py")
                                                               (om::abort-eval))))                                                                            
                                       (om-set-focus self)))

                                            
                     :begin-edit-action #'(lambda (item)
                                             (om-set-fg-color item (om-def-color :dark-gray)))

                     :edit-action #'(lambda (item)
                                       (let ((textsize (length (om-dialog-item-text item))))
                                         (om-set-fg-color item (om-def-color :dark-gray))
                                         (om-set-view-size item (om-make-point (list :character (+ 2 textsize)) 20))
                                         ))

                     :completion completion-fun
                     :font (om-def-font :font1)
                     :size (om-make-point 100 30)
                     :position position
                     :border t)))
    
    (om-add-subviews self textinput)
    (om-set-text-focus textinput t)
    t))

;; =====================================================


(defmethod make-new-py-box ((self patch-editor-view))
  (let ((mp (om-mouse-position self)))
    (enter-new-py-script self (if (om-point-in-rect-p mp 0 0 (w self) (h self))
                            mp (om-make-point (round (w self) 2) (round (h self) 2)))
                   :py)
    ))

;; ========================================================================================

(defmethod editor-key-action ((editor patch-editor) key)
  (declare (special *general-player*))

  (let* ((panel (get-editor-view-for-action editor))
         (selected-boxes (get-selected-boxes editor))
         (selected-connections (get-selected-connections editor))
         (player-active (and (boundp '*general-player*) *general-player*)))

(when panel

      (case key

        ;;; play/stop commands
        (#\Space (when player-active (play/stop-boxes selected-boxes)))
        (#\s (when player-active (stop-boxes selected-boxes)))

        (:om-key-delete (unless (edit-lock editor)
                          (store-current-state-for-undo editor)
                          (remove-selection editor)))

        (#\n (if selected-boxes
                 (mapc 'set-show-name selected-boxes)
               (unless (edit-lock editor)
                 (make-new-box panel))))

        (#\p (unless (edit-lock editor)
               (make-new-abstraction-box panel)))

        
        (:om-key-left (unless (edit-lock editor)
                        (if (om-option-key-p)
                            (when selected-boxes
                              (store-current-state-for-undo editor)
                              (mapc 'optional-input-- selected-boxes))
                          (let ((selection (or selected-boxes selected-connections)))
                            (store-current-state-for-undo editor :action :move :item selection)
                            (mapc
                             #'(lambda (f) (move-box f (if (om-shift-key-p) -10 -1) 0))
                             selection))
                          )))
        (:om-key-right (unless (edit-lock editor)
                         (if (om-option-key-p)
                             (when selected-boxes
                               (store-current-state-for-undo editor)
                               (mapc 'optional-input++ selected-boxes))
                           (let ((selection (or selected-boxes selected-connections)))
                             (store-current-state-for-undo editor :action :move :item selection)
                             (mapc #'(lambda (f) (move-box f (if (om-shift-key-p) 10 1) 0))
                                   selection))
                           )))
        (:om-key-up (unless (edit-lock editor)
                      (store-current-state-for-undo editor :action :move :item (or selected-boxes selected-connections))
                      (mapc #'(lambda (f) (move-box f 0 (if (om-shift-key-p) -10 -1)))
                            (or selected-boxes selected-connections))
                      ))
        (:om-key-down (unless (edit-lock editor)
                        (store-current-state-for-undo editor :action :move :item (or selected-boxes selected-connections))
                        (mapc #'(lambda (f) (move-box f 0 (if (om-shift-key-p) 10 1)))
                              (or selected-boxes selected-connections))
                        ))

        (#\k (unless (edit-lock editor)
               (when selected-boxes
                 (store-current-state-for-undo editor)
                 (mapc 'keyword-input++ selected-boxes))))
        (#\+ (unless (edit-lock editor)
               (when selected-boxes
                 (store-current-state-for-undo editor)
                 (mapc 'keyword-input++ selected-boxes))))
        (#\K (unless (edit-lock editor)
               (when selected-boxes
                 (store-current-state-for-undo editor)
                 (mapc 'keyword-input-- selected-boxes))))
        (#\- (unless (edit-lock editor)
               (when selected-boxes
                 (store-current-state-for-undo editor)
                 (mapc 'keyword-input-- selected-boxes))))

        (#\> (unless (edit-lock editor)
               (when selected-boxes
                 (store-current-state-for-undo editor)
                 (mapc 'optional-input++ selected-boxes))))
        (#\< (unless (edit-lock editor)
               (when selected-boxes
                 (store-current-state-for-undo editor)
                 (mapc 'optional-input-- selected-boxes))))

        (#\b (when selected-boxes
               (store-current-state-for-undo editor)
               (mapc 'switch-lock-mode selected-boxes)))

       (#\c (unless (edit-lock editor)
                     (store-current-state-for-undo editor)
                     (if selected-boxes
                            (auto-connect-box selected-boxes editor panel)
                            (make-new-comment panel))))

       ;; ================================================================

        (#\1 (unless (or (edit-lock editor) (get-pref-value :general :auto-ev-once-mode))
               (when selected-boxes
                 (store-current-state-for-undo editor)
                 (mapc 'switch-evonce-mode selected-boxes))))

        (#\l (unless (edit-lock editor)
               (when selected-boxes
                 (store-current-state-for-undo editor)
                 (mapc 'switch-lambda-mode selected-boxes))))

        (#\m (mapc 'change-display selected-boxes))


        ;;; Box editing
        ;;; => menu commands ?

        (#\A (unless (edit-lock editor)
               (store-current-state-for-undo editor)
               (align-selected-boxes editor)))

        (#\S (unless (edit-lock editor)
               (store-current-state-for-undo editor)
               (let ((selection (append selected-boxes selected-connections)))
                 (mapc 'consolidate-appearance selection)
                 (update-inspector-for-editor editor nil t))))

        (#\c (unless (edit-lock editor)
               (store-current-state-for-undo editor)
               (if selected-boxes
                   (auto-connect-box selected-boxes editor panel)
                 (make-new-comment panel))))

        (#\C (unless (edit-lock editor)
               (store-current-state-for-undo editor)
               (auto-connect-seq selected-boxes editor panel)))

        (#\r (unless (edit-lock editor)
                     (store-current-state-for-undo editor)
                     (mapc 'set-reactive-mode (or selected-boxes selected-connections))))

        (#\i (unless (edit-lock editor)
               (store-current-state-for-undo editor)
               (mapc 'initialize-size (or selected-boxes selected-connections))))

        (#\I (mapc 'initialize-box-value selected-boxes))

        (#\r (unless (edit-lock editor)
               (store-current-state-for-undo editor)
               (mapc 'set-reactive-mode (or selected-boxes selected-connections))))

        ;;; abstractions
        (#\a (unless (edit-lock editor)
               (when selected-boxes
                 (store-current-state-for-undo editor)
                 (mapc 'internalize-abstraction selected-boxes))))

        (#\E (unless (edit-lock editor)
               (encapsulate-patchboxes editor panel selected-boxes)))

        (#\U (unless (edit-lock editor)
               (unencapsulate-patchboxes editor panel selected-boxes)))

        (#\L (unless (edit-lock editor)
               (store-current-state-for-undo editor)
               (list-boxes editor panel selected-boxes)))

        (#\v (eval-editor-boxes editor selected-boxes))

        (#\w (om-debug))

        (#\h (funcall (help-command editor)))

        (#\d (when selected-boxes
               (mapcar #'print-help-for-box selected-boxes)))

        
        ; ======================================== 
        ; ========== OM-PY =======================
        ; ========================================

       (#\z (if (and selected-boxes (or (equal (type-of (car (om::list! selected-boxes))) 'omboxpy) 
                                           (equal (type-of (car (om::list! selected-boxes))) 'OMBox-run-py)))

              ; if omboxpy or OMBox-run-py is selected, then open the VS-code
              
              (let* ()
                     (om::om-print "Opening VScode!" "OM-Py")
                     (defparameter *vscode-opened* t)
                     (open-vscode selected-boxes))

              ; if nothing is selected, then new py-script

              (unless (edit-lock editor)
                     (make-new-py-box panel))))
        
       ; ======================================== 
       ; ========== OM-PY =======================
       ; ======================================== 
        
       (otherwise nil)))))

;; ====================================================================================================

(if (> 1.6 (read-from-string *version-string*))
       (let* ()
              (om-beep-msg "OM-Sharp is out of date. Please update to the latest version.")))

; ====================================================================================================

(if (equal *app-name* "om-sharp")
  (let* ()
          (add-preference-section :externals "OM-py" nil '(:py-enviroment :py-scripts :check-updates))
          (add-preference :externals :py-enviroment "Python Enviroment" :path nil)
          (add-preference :externals :py-scripts "Python Scripts" :folder (merge-pathnames "Py-Scripts/" (lib-resources-folder (find-library "OM-py"))))
          (add-preference :externals :check-updates "Online checking of updates" :bool t "If checked, om-py will look for new updates.")))

(if (or (null (get-pref-value :externals :py-enviroment)) (equal (get-pref-value :externals :py-enviroment) ""))
       nil
       #+windows (setq om-py::*activate-virtual-enviroment* (om-py::py-list->string (list (get-pref-value :externals :py-enviroment))))
       #+linux (setq (om::string+ "bash " (get-pref-value :externals :py-enviroment)))
       #+macos (setq (om::string+ "source " (get-pref-value :externals :py-enviroment))))