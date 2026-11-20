(load (compile-file "sum-lparallel.lisp"))
(sb-ext:save-lisp-and-die "sum-lparallel" :executable t :toplevel #'sum-lparallel:main)
