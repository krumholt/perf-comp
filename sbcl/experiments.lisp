;;;; SBCL tuning experiments for the 1..1e9 double-float sum.
;;;; Run: sbcl --script experiments.lisp   (inside the container)

(declaim (optimize (speed 3) (safety 0) (debug 0)))

(defconstant +target+ 1000000000)
(deftype u32 () '(unsigned-byte 32))

;;; 1. Baseline: same kernel as sum.lisp
(defun k-baseline (from to)
  (declare (type u32 from to))
  (let ((sum 0d0))
    (declare (type double-float sum))
    (loop for i of-type u32 from from to to
          do (incf sum (coerce i 'double-float)))
    sum))

;;; 2. Counter kept as a double: no int->double convert, no fixnum untagging
(defun k-double-counter (from to)
  (declare (type u32 from to))
  (let ((sum 0d0) (x (coerce from 'double-float)) (end (coerce to 'double-float)))
    (declare (type double-float sum x end))
    (loop while (<= x end)
          do (incf sum x) (incf x 1d0))
    sum))

;;; 3. Four independent accumulators: breaks the ADDSD latency chain
(defun k-4acc (from to)
  (declare (type u32 from to))
  (let ((s0 0d0) (s1 0d0) (s2 0d0) (s3 0d0)
        (x (coerce from 'double-float))
        (n (1+ (- to from))))
    (declare (type double-float s0 s1 s2 s3 x) (type fixnum n))
    (loop repeat (floor n 4)
          do (incf s0 x) (incf s1 (+ x 1d0)) (incf s2 (+ x 2d0)) (incf s3 (+ x 3d0))
             (incf x 4d0))
    (loop repeat (mod n 4) do (incf s0 x) (incf x 1d0))
    (+ (+ s0 s1) (+ s2 s3))))

;;; 4. Eight accumulators
(defun k-8acc (from to)
  (declare (type u32 from to))
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

;;; Parallel driver: split into NCHUNKS pieces, NTHREADS workers pull chunks
;;; from a shared atomic counter (dynamic load balancing, like rayon).
(defun par-sum (kernel nthreads nchunks)
  (declare (type function kernel) (type fixnum nthreads nchunks))
  (let* ((chunk (ceiling +target+ nchunks))
         (next (list 0))
         (threads
           (loop repeat nthreads
                 collect (sb-thread:make-thread
                          (lambda ()
                            (let ((acc 0d0))
                              (declare (type double-float acc))
                              (loop for k of-type fixnum = (sb-ext:atomic-incf (car next))
                                    while (< k nchunks)
                                    do (let ((from (1+ (* k chunk)))
                                             (to (min +target+ (* (1+ k) chunk))))
                                         (when (<= from to)
                                           (incf acc (the double-float (funcall kernel from to))))))
                              acc))))))
    (let ((sum 0d0))
      (declare (type double-float sum))
      (dolist (th threads sum)
        (incf sum (the double-float (sb-thread:join-thread th)))))))

(defun ms-since (t0)
  (round (* 1000 (- (get-internal-real-time) t0)) internal-time-units-per-second))

(defun bench (label fn &optional (runs 3))
  (funcall fn) ; warm-up
  (let ((times '()) result)
    (dotimes (r runs)
      (let ((t0 (get-internal-real-time)))
        (setf result (funcall fn))
        (push (ms-since t0) times)))
    (format t "~32A ~6D ms  (runs: ~{~D~^ ~})  sum=~,1F~%"
            label (reduce #'min times) (reverse times) result)))

(let ((nt (parse-integer (string-trim '(#\Newline)
                           (with-output-to-string (s)
                             (sb-ext:run-program "/usr/bin/nproc" '() :output s))))))
  (format t "SBCL ~A, ~D CPUs~%~%-- serial --~%" (lisp-implementation-version) nt)
  (bench "baseline"            (lambda () (k-baseline 1 +target+)))
  (bench "double counter"      (lambda () (k-double-counter 1 +target+)))
  (bench "4 accumulators"      (lambda () (k-4acc 1 +target+)))
  (bench "8 accumulators"      (lambda () (k-8acc 1 +target+)))
  (format t "~%-- parallel (~D threads) --~%" nt)
  (bench "baseline, 16 chunks"   (lambda () (par-sum #'k-baseline nt nt)))
  (bench "baseline, 256 chunks"  (lambda () (par-sum #'k-baseline nt 256)))
  (bench "4acc, 16 chunks"       (lambda () (par-sum #'k-4acc nt nt)))
  (bench "4acc, 256 chunks"      (lambda () (par-sum #'k-4acc nt 256)))
  (bench "8acc, 256 chunks"      (lambda () (par-sum #'k-8acc nt 256))))
