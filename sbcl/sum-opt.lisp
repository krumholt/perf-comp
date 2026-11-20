;;;; Optimized SBCL benchmark. Same algorithm as rust/src/bin/opt.rs and
;;;; csharp-opt: 8 independent accumulators with a double-float counter;
;;;; parallel = 256 chunks pulled from a shared atomic counter.

(declaim (optimize (speed 3) (safety 0) (debug 0)))

(defconstant +target+ 1000000000)
(defconstant +chunks+ 256)
(deftype u32 () '(unsigned-byte 32))

(defun kernel (from to)
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
