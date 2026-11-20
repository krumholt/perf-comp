;;;; Parallel sum with lparallel: pmap-reduce over 256 chunk indices.
;;;; Same per-chunk loop as the succinct version in beauty-competition.md.

(eval-when (:compile-toplevel :load-toplevel :execute)
  (ql:quickload :lparallel :silent t))

(defconstant +n+ 1000000000)
(defconstant +chunks+ 256)

(defun chunk-sum (j)
  (let ((lo (1+ (* j (floor +n+ +chunks+)))) (hi (* (1+ j) (floor +n+ +chunks+))))
    (loop for i fixnum from lo to hi sum (float i 1d0) of-type double-float)))

(defun main ()
  (let* ((cpus (parse-integer (string-trim '(#\Newline)
                                (with-output-to-string (s)
                                  (sb-ext:run-program "/usr/bin/nproc" '() :output s)))))
         (t0 (get-internal-real-time)))
    ;; kernel (thread pool) creation is inside the timed region, like rayon's
    (setf lparallel:*kernel* (lparallel:make-kernel cpus))
    (let ((sum (lparallel:pmap-reduce #'chunk-sum #'+
                                      (loop for j below +chunks+ collect j)
                                      :parts +chunks+)))
      (format t "Parallel Sum: ~,1F  Sum Time: ~D ms~%" sum
              (round (* 1000 (- (get-internal-real-time) t0))
                     internal-time-units-per-second)))
    (lparallel:end-kernel)))
