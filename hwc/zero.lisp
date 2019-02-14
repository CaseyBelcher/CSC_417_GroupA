#!/usr/bin/env clisp
;  vim: set filetype=lisp tabstop=2 shiftwidth=2 expandtab :

(defun test1()
  (let ((x 0))
    (dolist (y '(1 2 3) x)
      (setf x (+ x y)) 
    )
  )
)

  (print (test1))
