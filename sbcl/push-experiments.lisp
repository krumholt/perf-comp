;;;; How far can the SBCL SIMD kernel go without inline assembly?
;;;; A macro generates kernel variants that differ only in how they are
;;;; written; the algorithm (independent f64.4 accumulators, counter vectors
;;;; stepped by a constant) stays the same as rust/src/bin/simd.rs.
;;;; Run: sbcl --non-interactive --load push-experiments.lisp

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require :sb-simd))

(defpackage :push
  (:use :cl)
  (:import-from :sb-simd-avx
                #:f64.4 #:make-f64.4 #:f64.4-broadcast #:f64.4+ #:f64.4-values))
(in-package :push)

(defconstant +n+ 1000000000)
(deftype u32 () '(unsigned-byte 32))

(defmacro define-simd-kernel (name &key (accs 4) (runtime-step nil))
  "Define (NAME from to) summing FROM..TO with ACCS f64.4 accumulators.
RUNTIME-STEP computes the step vector from a value the compiler cannot
constant-fold, so it lives in a register instead of being reloaded."
  (let* ((width (* 4 accs))
         (as (loop for k below accs collect (intern (format nil "A~D" k))))
         (vs (loop for k below accs collect (intern (format nil "V~D" k)))))
    `(defun ,name (from to)
       (declare (type u32 from to) (optimize (speed 3) (safety 0) (debug 0)))
       (let* ((n (1+ (- to from)))
              (x (coerce from 'double-float))
              (base (make-f64.4 x (+ x 1d0) (+ x 2d0) (+ x 3d0)))
              (step ,(if runtime-step
                         ;; (x + W) - x is W, but not foldable at compile time
                         `(f64.4-broadcast (- (+ x ,(coerce width 'double-float)) x))
                         `(f64.4-broadcast ,(coerce width 'double-float))))
              ,@(loop for v in vs for k from 0
                      collect `(,v (f64.4+ base (f64.4-broadcast ,(coerce (* 4 k) 'double-float)))))
              ,@(loop for a in as collect `(,a (f64.4-broadcast 0d0))))
         (declare (type fixnum n) (type double-float x)
                  (type f64.4 base step ,@vs ,@as))
         (loop repeat (floor n ,width)
               do (setf ,@(loop for a in as for v in vs
                                append `(,a (f64.4+ ,a ,v) ,v (f64.4+ ,v step)))))
         (let ((acc ,(reduce (lambda (p q) `(f64.4+ ,p ,q)) as)))
           (multiple-value-bind (l0 l1 l2 l3) (f64.4-values acc)
             (declare (type double-float l0 l1 l2 l3))
             (let ((sum (+ (+ l0 l1) (+ l2 l3)))
                   (tt (+ x (coerce (* ,width (floor n ,width)) 'double-float))))
               (declare (type double-float sum tt))
               (loop repeat (mod n ,width) do (incf sum tt) (incf tt 1d0))
               sum)))))))

(define-simd-kernel k4-const   :accs 4)                    ; = sum-simd.lisp
(define-simd-kernel k4-runtime :accs 4 :runtime-step t)
(define-simd-kernel k8-const   :accs 8)
(define-simd-kernel k8-runtime :accs 8 :runtime-step t)
(define-simd-kernel k2-runtime :accs 2 :runtime-step t)

(defun par (kernel nthreads &optional (nchunks 256))
  (let* ((chunk (ceiling +n+ nchunks))
         (next (list 0))
         (threads
           (loop repeat nthreads
                 collect (sb-thread:make-thread
                          (lambda ()
                            (let ((acc 0d0))
                              (declare (type double-float acc))
                              (loop for k of-type fixnum = (sb-ext:atomic-incf (car next))
                                    while (< k nchunks)
                                    do (incf acc (the double-float
                                                      (funcall kernel (1+ (* k chunk))
                                                               (min +n+ (* (1+ k) chunk))))))
                              acc))))))
    (reduce #'+ (mapcar #'sb-thread:join-thread threads))))

(defun ms-since (t0)
  (round (* 1000 (- (get-internal-real-time) t0)) internal-time-units-per-second))

(defmacro bench (label form)
  `(let ((times '()) r)
     (dotimes (i 5)
       (let ((t0 (get-internal-real-time)))
         (setf r ,form)
         (push (ms-since t0) times)))
     (format t "~28A best ~3D ms  runs:~{ ~3D~}  sum=~,1F~%"
             ,label (reduce #'min times) (reverse times) r)))

(defun count-loop-insns (fn)
  "Instructions between the loop label L0 and L1 in FN's disassembly."
  (let* ((text (with-output-to-string (*standard-output*) (disassemble fn)))
         (lines (with-input-from-string (s text)
                  (loop for l = (read-line s nil) while l collect l)))
         (start (position-if (lambda (l) (search " L0:" l)) lines))
         (end (position-if (lambda (l) (search " L1:" l)) lines :start (1+ (or start 0)))))
    (if (and start end)
        (let ((body (subseq lines start end)))
          (format nil "~D insns (~D vaddpd, ~D loads, ~D moves)"
                  (length body)
                  (count-if (lambda (l) (search "VADDPD" l)) body)
                  (count-if (lambda (l) (search "VMOVUPS" l)) body)
                  (count-if (lambda (l) (search "VMOVAPS" l)) body)))
        "?")))

(let ((nt (parse-integer (string-trim '(#\Newline)
                           (with-output-to-string (s)
                             (sb-ext:run-program "/usr/bin/nproc" '() :output s)))))
      (kernels '(k4-const k4-runtime k8-const k8-runtime k2-runtime)))
  (format t "-- inner loop --~%")
  (dolist (k kernels) (format t "~12A ~A~%" k (count-loop-insns (symbol-function k))))
  (format t "~%-- serial --~%")
  (dolist (k kernels)
    (let ((f (symbol-function k))) (bench (string-downcase k) (funcall f 1 +n+))))
  (format t "~%-- parallel (~D threads, 256 chunks) --~%" nt)
  (dolist (k kernels)
    (let ((f (symbol-function k))) (bench (string-downcase k) (par f nt)))))
