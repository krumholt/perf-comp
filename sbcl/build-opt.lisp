(load (compile-file "sum-opt.lisp"))
(sb-ext:save-lisp-and-die "sum-opt" :executable t :toplevel #'main)
