;;            OM-py
;;
;;      by Charles K. Neimog 
;; University of São Paulo (2021-2022)
           
; =============================

(in-package :om)

; =============================

(defun lib-src-file (file)
    (merge-pathnames file (om-make-pathname :directory *load-pathname*)))

; =============================

(mapcar (lambda (file) (compile&load (lib-src-file file) t t))
        '(
            "sources/package"
            "sources/OM/OM-py"
            "sources/OM/OM-Functions"
            "sources/OM/pythonpatcheditor"
            ))

; ========================================

(om::fill-library '((nil nil nil nil nil)))

; ========================================

             

