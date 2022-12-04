   
(defun add-box-in-patch-panel (str scroller pos)      

(read-from-string str)

  (let ((*package* (find-package :om))
        (funname (read-from-string str))
        (args (decode-input-arguments str))
        (text (cadr (multiple-value-list (string-until-char str " "))))   
        newbox)
    (cond
       ((or (listp funname) (numberp funname) (stringp funname))
        (setf newbox (omNG-make-new-boxcall (get-basic-type 'list) pos (mk-unique-name scroller "list")))
        (setf (value newbox) funname)
        (setf (thestring newbox) str)
        (setf (frame-size newbox) nil)) ; (get-good-size newtext *om-default-font2*)))
       ((special-form-p funname)
        (om-beep-msg  (string+ "Special Lisp form " str)))
       
       ((equal funname 'patch)
        (setf newbox (omNG-make-new-boxcall 
                      (make-instance 'OMPatchAbs 
                        :name (mk-unique-name scroller "mypatch") :icon 210) 
                      pos 
                      (mk-unique-name scroller "mypatch"))))
        
        ;; ===================================================================
        ((equal funname 'lisp)
            (setf newbox (omNG-make-new-boxcall 
                      (make-instance 'OMLispPatchAbs 
                        :name (mk-unique-name scroller "lispfunction")
                        :icon 123)
                      pos 
                      (mk-unique-name scroller "lispfunction"))))

        ;; ===================================================================
        
        ((equal funname 'py)
            (progn 
                (setf newbox (omNG-make-new-boxcall 
                        (make-instance 'OMpythonPatchAbs 
                            :name (mk-unique-name scroller "PythonFunction")
                            :icon 1997) ;; Need to be inside the OM Folder
                        pos 
                        (mk-unique-name scroller "PythonFunction")))))

        ;; ===================================================================

       ((member funname *spec-new-boxes-types*)
        (setf newbox (get-new-box-from-type funname pos scroller)))

       ((equal funname 'maquette)
        (setf newbox (omNG-make-new-boxcall 
                      (make-instance 'OMMaqAbs 
                                     :name (mk-unique-name scroller "mymaquette") :icon 265) 
                      pos 
                      (mk-unique-name scroller "mymaquette"))))


       ((equal funname 'comment)
        (setf newbox (omNG-make-new-boxcall funname pos "comment"))
        (setf (reference newbox) (or text "Type your comments here")))
        
       ((and (find-class funname nil) (not (equal funname 'list)) (omclass-p (class-of (find-class funname nil))))
        (cond ((om-shift-key-p)
               (setf newbox  (omNG-make-new-boxcall-slots (find-class funname nil) pos (mk-unique-name scroller "slots"))))
              (t (let ((boxname (or text (mk-unique-name scroller (string funname)))))
                   (setf newbox (omNG-make-new-boxcall (find-class funname) pos boxname))
                   (if text (setf (show-name newbox) t))))
              ))
       ((not (fboundp funname))
        (if (equal funname '??)
            (om-beep)
          (om-beep-msg  (string+ "function " str " does not exist!"))))
       ((OMGenfun-p (fdefinition funname))
	(setf newbox (omNG-make-new-boxcall (fdefinition funname) pos 
                                            (mk-unique-name scroller (string funname))))
        (when args (add-args-to-box newbox args))
        )
       
       (t (setf newbox (omNG-make-new-lispboxcall funname pos 
                                                  (mk-unique-name scroller (string funname))))
          (when args (add-args-to-box newbox args)))
       )

    (when (and newbox (box-allowed-p newbox scroller))
      (when (and (allow-rename newbox) (car args))
        (set-patch-box-name newbox text))
      
      (omG-add-element scroller (make-frame-from-callobj newbox)))
      (when (equal funname 'comment)
        (reinit-size (car (frames newbox))))  
    newbox))  ;;; so validity of string as a new object can be tested


; =================================================================================================
; =================================================================================================

(defmethod om-get-menu-context ((self PatchPanel))
  (let ((posi (om-mouse-position self))
        (sel (car (get-selected-picts self))))
    (if sel
        (get-pict-menu-context sel self)
      (list 
       (om-new-leafmenu "Comment" #'(lambda () 
                                      (let ((newbox (omNG-make-new-boxcall 'comment posi "comment")))
                                        (when newbox
                                          (omG-add-element self (make-frame-from-callobj newbox))
                                          (reinit-size (car (frames  newbox)))))))
       (om-new-leafmenu "Picture" #'(lambda () 
                                      (make-bg-pict self posi)))
       (list 
        (om-package-fun2menu *om-package-tree* nil #'(lambda (f) (add-box-from-menu f posi)))
        (om-package-classes2menu *om-package-tree* nil #'(lambda (c) (add-box-from-menu c posi)))
        )
       (list 
        (om-new-menu "Internal..." 
                     (om-new-leafmenu "Patch" #'(lambda () (omG-add-element self (make-frame-from-callobj 
                                                                                  (omNG-make-new-boxcall 
                                                                                   (make-instance 'OMPatchAbs :name "mypatch" :icon 210)
                                                                                   posi (mk-unique-name self "mypatch"))))))
                     (om-new-leafmenu "Maquette" #'(lambda () (omG-add-element self (make-frame-from-callobj 
                                                                                     (omNG-make-new-boxcall 
                                                                                      (make-instance 'OMMaqAbs :name "mymaquette" :icon 265)
                                                                                      posi (mk-unique-name self "mymaquette"))))))
                     (om-new-leafmenu "Loop" #'(lambda () (add-box-from-menu (fdefinition 'omloop) posi)))
                     (om-new-leafmenu "Python Function" #'(lambda () (omG-add-element self 
                                                                                    (make-frame-from-callobj 
                                                                                     (omNG-make-new-boxcall 
                                                                                      (make-instance 'OMPythonPatchAbs :name "pythonfunction" :icon 1997)
                                                                                      posi (mk-unique-name self "pythonfunction"))))))
                     (om-new-leafmenu "Lisp Function" #'(lambda () (omG-add-element self 
                                                                                    (make-frame-from-callobj 
                                                                                     (omNG-make-new-boxcall 
                                                                                      (make-instance 'OMLispPatchAbs :name "lispfunction" :icon 123)
                                                                                      posi (mk-unique-name self "lispfunction"))))))))
       (list
        (om-new-leafmenu "Input" #'(lambda () (add-input self posi)) nil (add-input-enabled self 'in))
        (om-new-leafmenu "Output" #'(lambda () (add-output self posi)) nil (add-output-enabled self 'out))
        (om-new-menu "TemporalBoxes" 
                     (om-new-leafmenu "Self Input" #'(lambda () (add-special-box 'tempin posi self)) nil (add-input-enabled self 'tempin))
                     (om-new-leafmenu "Maq. Self Input" #'(lambda () (add-special-box 'maq-tempin posi self)) nil (add-input-enabled self 'maq-tempin))
                     (om-new-leafmenu "Temporal Output" #'(lambda () (add-special-box 'tempout posi self)) nil (add-output-enabled self 'tempout)))
        )
       (om-new-leafmenu "Last Saved"  #'(lambda () (window-last-saved (editor self))) nil (if (and 
                                                                                               (mypathname (object self))
                                                                                               (not (subtypep (class-of self) 'methodpanel))) t nil))
       ))))