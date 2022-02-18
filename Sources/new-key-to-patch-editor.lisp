(in-package :om)

;; ==========================================================================
(defvar *vscode-is-openned* nil)

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
       (defvar *vscode-is-openned* t)))
    

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
       (defvar *vscode-is-openned* nil)
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

        (otherwise nil))
      )))



;; ====================================================================================================

(defmethod load-om-library ((lib OMLib))
  (let ((lib-file (lib-loader-file lib)))
    (if lib-file
        (handler-bind ((error #'(lambda (c)
                                  (progn
                                    (om-message-dialog (format nil "Error while loading the library ~A:~%~s"
                                                               (name lib) (format nil "~A" c)))
                                    (abort c)))))

          (om-print-format "~%~%Loading library: ~A..." (list lib-file))
          (let* ((*current-lib* lib)
                 (file-contents (list-from-file lib-file))
                 (lib-data (find-values-in-prop-list file-contents :om-lib))
                 (version (find-value-in-kv-list lib-data :version))
                 (author (find-value-in-kv-list lib-data :author))
                 (doc (find-value-in-kv-list lib-data :doc))
                 (files (find-values-in-prop-list lib-data :source-files))
                 (symbols (find-values-in-prop-list lib-data :symbols)))

            ;;; update the metadata ?
            (setf (version lib) version
                  (doc lib) doc
                  (author lib) author)

            (CleanupPackage lib)

            ;;; load sources
            (with-relative-ref-path
                (mypathname lib)

              ;;; temp: avoid fasl conflicts for now
              ;; (cl-user::clean-sources (mypathname lib))

              (mapc #'(lambda (f)
                        (let ((path (omng-load f)))

                          ;;; supports both pathnames "om-formatted", and raw pathnames and strings
                          (when (equal (car (pathname-directory path)) :relative)
                            ;;; merge-pathname is not safe here as it sets the pathname-type to :unspecific (breaks load/compile functions)
                            (setf path (om-relative-path (cdr (pathname-directory path)) (pathname-name path) (mypathname lib)))
                            )

                          (if (string-equal (pathname-name path) "load") ; hack => document that !!
                              (load path)
                            (compile&load path t t (om::om-relative-path '(".om#") nil path)))
                          ))
                    files)
              )
            ;;; set packages
              (mapc #'(lambda (class) (addclass2pack class lib))
                  (find-values-in-prop-list symbols :classes))
              (mapc #'(lambda (fun) (addFun2Pack fun lib))
                  (find-values-in-prop-list symbols :functions))


              (mapc #'(lambda (item)
                      (addspecialitem2pack item lib))
                  (find-values-in-prop-list symbols :special-items))

            (mapc #'(lambda (pk)
                      (let ((new-pack (omng-load pk)))
                        (addpackage2pack new-pack lib)))
                  (find-values-in-prop-list symbols :packages))

            (set-om-pack-symbols) ;; brutal...

            (register-images (lib-icons-folder lib))

            (setf (loaded? lib) t)
            (update-preference-window-module :libraries) ;;; update if the window is opened
            (update-preference-window-module :externals) ;;; update if the window is opened

            (gen-lib-reference lib)

            (om-print-format "~%==============================================")
            (om-print-format "~A ~A" (list (name lib) (or (version lib) "")))
            (when (doc lib) (om-print-format "~&~A" (list (doc lib))))
            (om-print-format "==============================================")

            lib-file))

      (om-beep-msg "Library doesn't have a loader file: ~A NOT FOUND.."
                   (om-make-pathname :directory (mypathname lib) :name (name lib) :type "olib")))
    ))


;; ====================================================================================================

(defmethod om-load-from-id ((id (eql :package)) data)
  (let* ((name (find-value-in-kv-list data :name))
         (pack (make-instance 'OMPackage :name (or name "Untitled Package"))))
    (mapc #'(lambda (class) (addclass2pack class pack)) (find-values-in-prop-list data :classes))
    (mapc #'(lambda (fun) (addFun2Pack fun pack)) (find-values-in-prop-list data :functions))
    (mapc #'(lambda (item) (addspecialitem2pack item pack)) (find-values-in-prop-list data :special-items))
    (mapc #'(lambda (spk)
              (let ((sub-pack (omng-load spk)))
                (addpackage2pack sub-pack pack)))
          (find-values-in-prop-list data :packages))

    pack))

;; ====================================================================================================

(defun make-libs-tab ()
  (let ((libs-tree-view (om-make-tree-view (subpackages *om-libs-root-package*)
                                           :size (omp 120 20)
                                           :expand-item 'get-sub-items
                                           :print-item 'get-name
                                           :font (om-def-font :font1)
                                           :bg-color (om-def-color :light-gray)
                                           :item-icon #'(lambda (item) (get-icon item))
                                           :icons (list :icon-pack 
                                                        :icon-fun 
                                                        :icon-genfun 
                                                        :icon-class 
                                                        :icon-special 
                                                        :icon-lib-loaded 
                                                        :icon-lib)
                                           ))
        (side-panel
         (om-make-di
          'om-multi-text
          :size (om-make-point nil nil)
          :font (om-def-font :font1)
          :fg-color (om-def-color :dark-gray)
          :text *libs-tab-text*)))

    (om-make-layout
     'om-row-layout :name "External Libraries"
     :subviews (list
                (om-make-layout
                 'om-column-layout  :align :right
                 :subviews (list libs-tree-view
                                 (om-make-di 'om-button :size (om-make-point nil 24)
                                             :font (om-def-font :font2)
                                             :text "Refresh list"
                                             :di-action #'(lambda (b)
                                                            (declare (ignore b))
                                                            (update-registered-libraries)
                                                            (update-libraries-tab *main-window*)))))
                :divider
                side-panel))
    ))
