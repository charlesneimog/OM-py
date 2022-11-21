   
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

                (print "Activando Function")
                (setf newbox (omNG-make-new-boxcall 
                        (make-instance 'OMpythonPatchAbs 
                            :name (mk-unique-name scroller "PythonFunction")
                            :icon 1997)
                        pos 
                        (mk-unique-name scroller "PythonFunction")))))


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