;;;; Parallel sums with lparallel: pmap-reduce over 256 chunk indices.
;;;; Three per-chunk kernels:
;;;;   plain - the succinct typed LOOP from beauty-competition.md
;;;;   8acc  - same kernel as sum-opt.lisp (8 accumulators, double counter)
;;;;   simd  - same kernel as sum-simd.lisp (sb-simd, 4 x f64.4 accumulators)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require :sb-simd)
  (ql:quickload :lparallel :silent t))

(defpackage :sum-lparallel
  (:use :cl)
  (:import-from :sb-simd-avx
                #:f64.4 #:make-f64.4 #:f64.4-broadcast #:f64.4+ #:f64.4-values)
  (:export #:main))
(in-package :sum-lparallel)

(defconstant +n+ 1000000000)
(defconstant +chunks+ 256)
(defconstant +chunk+ (floor +n+ +chunks+))
(deftype u32 () '(unsigned-byte 32))

(defun plain-kernel (lo hi)
  (loop for i fixnum from lo to hi sum (float i 1d0) of-type double-float))

(defun kernel-8acc (from to)
  (declare (type u32 from to) (optimize (speed 3) (safety 0) (debug 0)))
  (let ((s0 0d0) (s1 0d0) (s2 0d0) (s3 0d0) (s4 0d0) (s5 0d0) (s6 0d0) (s7 0d0)
        (x (coerce from 'double-float))
        (n (1+ (- to from))))
    (declare (type double-float s0 s1 s2 s3 s4 s5 s6 s7 x) (type fixnum n))
    (loop repeat (floor n 8)
          do (incf s0 x)          (incf s1 (+ x 1d0)) (incf s2 (+ x 2d0)) (incf s3 (+ x 3d0))
             (incf s4 (+ x 4d0)) (incf s5 (+ x 5d0)) (incf s6 (+ x 6d0)) (incf s7 (+ x 7d0))
             (incf x 8d0))
    (loop repeat (mod n 8) do (incf s0 x) (incf x 1d0))
    (+ (+ (+ s0 s1) (+ s2 s3)) (+ (+ s4 s5) (+ s6 s7)))))

(defun kernel-simd (from to)
  (declare (type u32 from to) (optimize (speed 3) (safety 0) (debug 0)))
  (let* ((n (1+ (- to from)))
         (x (coerce from 'double-float))
         (v0 (make-f64.4 x (+ x 1d0) (+ x 2d0) (+ x 3d0)))
         (v1 (f64.4+ v0 (f64.4-broadcast 4d0)))
         (v2 (f64.4+ v0 (f64.4-broadcast 8d0)))
         (v3 (f64.4+ v0 (f64.4-broadcast 12d0)))
         (step (f64.4-broadcast 16d0))
         (a0 (f64.4-broadcast 0d0)) (a1 a0) (a2 a0) (a3 a0))
    (declare (type fixnum n) (type double-float x)
             (type f64.4 v0 v1 v2 v3 step a0 a1 a2 a3))
    (loop repeat (floor n 16)
          do (setf a0 (f64.4+ a0 v0) v0 (f64.4+ v0 step)
                   a1 (f64.4+ a1 v1) v1 (f64.4+ v1 step)
                   a2 (f64.4+ a2 v2) v2 (f64.4+ v2 step)
                   a3 (f64.4+ a3 v3) v3 (f64.4+ v3 step)))
    (multiple-value-bind (l0 l1 l2 l3) (f64.4-values (f64.4+ (f64.4+ a0 a1) (f64.4+ a2 a3)))
      (declare (type double-float l0 l1 l2 l3))
      (let ((sum (+ (+ l0 l1) (+ l2 l3)))
            (tt (+ x (coerce (* 16 (floor n 16)) 'double-float))))
        (declare (type double-float sum tt))
        (loop repeat (mod n 16) do (incf sum tt) (incf tt 1d0))
        sum))))

(defun psum (kernel cpus)
  "Create a kernel (thread pool), pmap-reduce KERNEL over the chunks, tear down."
  (setf lparallel:*kernel* (lparallel:make-kernel cpus))
  (unwind-protect
       (lparallel:pmap-reduce (lambda (j) (funcall kernel (1+ (* j +chunk+)) (* (1+ j) +chunk+)))
                              #'+ (alexandria:iota +chunks+) :parts +chunks+)
    (lparallel:end-kernel :wait t)))

(defun main ()
  (let ((cpus (parse-integer (string-trim '(#\Newline)
                               (with-output-to-string (s)
                                 (sb-ext:run-program "/usr/bin/nproc" '() :output s))))))
    ;; pool creation is inside each timed region, like rayon's
    (loop for (label kernel) in `(("Plain" ,#'plain-kernel)
                                  ("8acc"  ,#'kernel-8acc)
                                  ("Simd"  ,#'kernel-simd))
          do (let* ((t0 (get-internal-real-time))
                    (sum (psum kernel cpus)))
               (format t "~A Parallel Sum: ~,1F  Sum Time: ~D ms~%" label sum
                       (round (* 1000 (- (get-internal-real-time) t0))
                              internal-time-units-per-second))))))
