(in-package :om)

;=========================================================================
;  OpenMusic: Visual Programming Language for Music Composition
;
;  Copyright (C) 1997-2009 IRCAM-Centre Georges Pompidou, Paris, France.
; 
;    This file is part of the OpenMusic environment sources
;
;    OpenMusic is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    OpenMusic is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with OpenMusic.  If not, see <http://www.gnu.org/licenses/>.
;
; Authors: Gerard Assayag, Augusto Agon, Jean Bresson
;=========================================================================

;DocFile
; py Patch editor window
;DocFile




(defmethod edit-new-lambda-expression ((self ompatch))
   
   (om-set-text (editorframe self) 
                (format nil 
                        ";;; Edit a valid LAMBDA EXPRESSION for ~s~%;;; e.g. (lambda (arg1 arg2 ...) ( ... ))~%~%(lambda () (om-beep))" 
                        (name self)))
   (om-add-menu-to-win (editorframe self))
   (setf (saved? self) nil)
   (editorframe self)
   )

(defmethod edit-existing-lambda-expression ((self ompatch))
   (let ((editor (om-make-window 'patch-lambda-exp-window
                                 :patchref self
                                 :size (om-make-point 300 200)
                                 :window-title (string+ "py Patch - " (name self))
                                 :window-show nil)))
     ;(om-set-text editor (format nil "~S" (py-exp-p self)))
     (om-set-text editor (py-exp self))
     (om-add-menu-to-win editor)
     editor))


