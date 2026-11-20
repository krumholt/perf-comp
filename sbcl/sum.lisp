;;;; Comparable SBCL benchmark: sum 1..1e9 as double-floats.
;;;; Runs a serial version (matches the C# program) and a parallel
;;;; version using sb-thread (matches the Rust/rayon program).

(declaim (optimize (speed 3) (safety 0) (debug 0)))

(defconstant +target+ 1000000000)

(defun sum-range (from to)
  "Sum the integers FROM..TO inclusive as double-floats."
  (declare (type (unsigned-byte 32) from to))
  (let ((sum 0d0))
    (declare (type double-float sum))
    (loop for i of-type (unsigned-byte 32) from from to to
          do (incf sum (coerce i 'double-float)))
    sum))

(defun sum-parallel (target nthreads)
  (declare (type (unsigned-byte 32) target) (type fixnum nthreads))
  (let* ((chunk (ceiling target nthreads))
         (threads
           (loop for k below nthreads
                 for from = (1+ (* k chunk))
                 for to = (min target (* (1+ k) chunk))
                 when (<= from to)
                   collect (let ((f from) (tt to))
                             (sb-thread:make-thread
                              (lambda () (sum-range f tt)))))))
    (let ((sum 0d0))
      (declare (type double-float sum))
      (dolist (th threads sum)
        (incf sum (the double-float (sb-thread:join-thread th)))))))

(defun now-ms ()
  (/ (get-internal-real-time) (/ internal-time-units-per-second 1000)))

(defun main ()
  (let* ((nthreads (or (ignore-errors
                        (parse-integer (string-trim '(#\Newline #\Space)
                                         (with-output-to-string (s)
                                           (sb-ext:run-program "/usr/bin/nproc" '() :output s)))))
                       1)))
    ;; serial (like C#)
    (let* ((t0 (now-ms))
           (sum (sum-range 1 +target+))
           (dt (round (- (now-ms) t0))))
      (format t "Serial   Sum: ~,1F  Sum Time: ~D ms~%" sum dt))
    ;; parallel (like Rust/rayon)
    (let* ((t0 (now-ms))
           (sum (sum-parallel +target+ nthreads))
           (dt (round (- (now-ms) t0))))
      (format t "Parallel Sum: ~,1F  Sum Time: ~D ms (~D threads)~%" sum dt nthreads))))
