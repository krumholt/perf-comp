;;;; Explicit AVX (256-bit) version using sb-simd. Same algorithm as
;;;; rust/src/bin/simd.rs and csharp-simd: 4 vector accumulators x 4 doubles
;;;; = 16 running sums; parallel = 256 chunks from a shared atomic counter.

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require :sb-simd))

(defpackage :sum-simd
  (:use :cl)
  (:import-from :sb-simd-avx
                #:f64.4 #:make-f64.4 #:f64.4-broadcast #:f64.4+ #:f64.4-values)
  (:export #:main))
(in-package :sum-simd)

(declaim (optimize (speed 3) (safety 0) (debug 0)))

(defconstant +target+ 1000000000)
(defconstant +chunks+ 256)
(deftype u32 () '(unsigned-byte 32))

(defun kernel (from to)
  (declare (type u32 from to))
  (let* ((n (1+ (- to from)))
         (x (coerce from 'double-float))
         ;; counters: [x..x+3], [x+4..x+7], [x+8..x+11], [x+12..x+15]
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
        ;; scalar tail
        (loop repeat (mod n 16) do (incf sum tt) (incf tt 1d0))
        sum))))

(defun sum-parallel (nthreads)
  (declare (type fixnum nthreads))
  (let* ((chunk (ceiling +target+ +chunks+))
         (next (list 0))
         (threads
           (loop repeat nthreads
                 collect (sb-thread:make-thread
                          (lambda ()
                            (let ((acc 0d0))
                              (declare (type double-float acc))
                              (loop for k of-type fixnum = (sb-ext:atomic-incf (car next))
                                    while (< k +chunks+)
                                    do (incf acc (kernel (1+ (* k chunk))
                                                         (min +target+ (* (1+ k) chunk)))))
                              acc))))))
    (let ((sum 0d0))
      (declare (type double-float sum))
      (dolist (th threads sum)
        (incf sum (the double-float (sb-thread:join-thread th)))))))

(defun ms-since (t0)
  (round (* 1000 (- (get-internal-real-time) t0)) internal-time-units-per-second))

(defun main ()
  (let ((nthreads (or (ignore-errors
                       (parse-integer (string-trim '(#\Newline #\Space)
                                        (with-output-to-string (s)
                                          (sb-ext:run-program "/usr/bin/nproc" '() :output s)))))
                      1)))
    (let* ((t0 (get-internal-real-time)) (sum (kernel 1 +target+)))
      (format t "Serial   Sum: ~,1F  Sum Time: ~D ms~%" sum (ms-since t0)))
    (let* ((t0 (get-internal-real-time)) (sum (sum-parallel nthreads)))
      (format t "Parallel Sum: ~,1F  Sum Time: ~D ms (~D threads)~%" sum (ms-since t0) nthreads))))
