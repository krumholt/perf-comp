(load (compile-file "sum-simd.lisp"))
(sb-ext:save-lisp-and-die "sum-simd" :executable t :toplevel #'sum-simd:main)
