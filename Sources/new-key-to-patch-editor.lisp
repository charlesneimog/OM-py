(in-package :om)

;; ==========================================================================
(defparameter *vscode-is-openned* nil)

(defun open-vscode (selected-boxes)

(let*  (
       (vs-code (read-from-string 
                     (reduce #'(lambda (s1 s2) 
                            (concatenate 'string s1 (string #\Newline) s2)) (text (reference (car (om::list! selected-boxes))))) nil))
       (add-lisp-var (om::string+ "#(" (write-to-string (first vs-code)) " " (write-to-string (second vs-code))))
       (path (om::save-as-text 
                     (om::string+ add-lisp-var (string #\Newline) (third vs-code))
                     (om::tmpfile (om::string+ "tmp-code-" (write-to-string (om::om-random 100 999)) ".py") :subdirs "om-py"))))
       
       (mp:process-run-function (string+ "VSCODE Running!") ;; Se não, a interface do OM trava
                                   () 
                                          (lambda () (vs-code-update-py-box path selected-boxes (second vs-code))))
       (defparameter *vscode-is-openned* t)))
    

;; ;; ==========================================================================

(defun vs-code-update-py-box (path selected-boxes variables) ;; Precisa ser um método????

(let* (
       (wait-edit-process (oa::om-command-line (om::string+ "code " (namestring path) " -w") nil))
       (get-var-in-py (car (om-py::get-lisp-variables path)))
       (remove-var-in-py (om-py::remove-lisp-var path))
       (read-edited-code 
              (om-py::py-list->string (list 
                                          (om-py::concatstring (mapcar (lambda (x) (om::string+ x (string #\Newline))) remove-var-in-py)))))
       (variables-in-lisp   (if    (null get-var-in-py)
                                   (x-append (om::string+ "(py_var " (write-to-string variables)) read-edited-code ")")
                                   (x-append get-var-in-py read-edited-code ")")))
       (from-box (if (equal (type-of (reference (car (om::list! selected-boxes)))) 'OMPyFunctionInternal)
                     (om::make-value 'OMPYFunction  (list (list :text variables-in-lisp)))
                     (om::make-value 'run-py-f  (list (list :text variables-in-lisp)))))
       (to-box (reference (car (om::list! selected-boxes)))))
       (copy-contents from-box to-box)
       (compile-patch to-box)
       (update-from-reference (car selected-boxes))
       (defparameter *vscode-is-openned* nil)
       (om-py::clear-the-file path)
       (om::om-print "Closing VScode!" "OM-Py")))
       
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

        
        ;;; OM py Function
        (#\c (when (and selected-boxes (or (equal (type-of (car (om::list! selected-boxes))) 'omboxpy) 
                                           (equal (type-of (car (om::list! selected-boxes))) 'OMBox-run-py)))
               (let* ()
               (om::om-print "Opening VScode!" "OM-Py")
               (defparameter *vscode-opened* t)
               (open-vscode selected-boxes))))

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

        (otherwise nil))
      )))