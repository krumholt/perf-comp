(load (compile-file "sum.lisp"))
(sb-ext:save-lisp-and-die "sum" :executable t :toplevel #'main)
