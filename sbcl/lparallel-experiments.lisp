;;;; lparallel styles for the 1..1e9 double sum. lparallel has no numeric range
;;;; type, so every version maps over chunk indices; the per-chunk loop is the
;;;; same typed LOOP as in beauty-competition.md.
;;;; Run: sbcl --non-interactive --load lparallel-experiments.lisp

(ql:quickload :lparallel :silent t)

(defconstant +n+ 1000000000)

(defun chunk-sum (j k)
  "Sum of chunk J of K equal chunks of 1..+N+."
  (let ((lo (1+ (* j (floor +n+ k)))) (hi (* (1+ j) (floor +n+ k))))
    (loop for i fixnum from lo to hi sum (float i 1d0) of-type double-float)))

;; 1. pmap-reduce over chunk indices
(defun v-pmap-reduce (k)
  (lparallel:pmap-reduce (lambda (j) (chunk-sum j k)) #'+
                         (loop for j below k collect j)))

;; 2. preduce over pmap (two parallel passes)
(defun v-preduce-pmap (k)
  (lparallel:preduce #'+ (lparallel:pmap 'vector (lambda (j) (chunk-sum j k))
                                         (loop for j below k collect j))))

;; 3. futures
(defun v-futures (k)
  (reduce #'+ (mapcar #'lparallel:force
                      (loop for j below k
                            collect (let ((j j)) (lparallel:future (chunk-sum j k)))))))

;; 4. pmapcar + reduce
(defun v-pmapcar (k)
  (reduce #'+ (lparallel:pmapcar (lambda (j) (chunk-sum j k))
                                 (loop for j below k collect j))))

(defun ms-since (t0)
  (round (* 1000 (- (get-internal-real-time) t0)) internal-time-units-per-second))

(defmacro bench (label form)
  `(let ((times '()) r)
     (dotimes (i 3)
       (let ((t0 (get-internal-real-time)))
         (setf r ,form)
         (push (ms-since t0) times)))
     (format t "~34A runs: ~{~4D~} ms  sum=~,1F~%" ,label (reverse times) r)))

(let ((cpus (parse-integer (string-trim '(#\Newline)
                             (with-output-to-string (s)
                               (sb-ext:run-program "/usr/bin/nproc" '() :output s))))))
  (format t "lparallel ~A, ~D workers~%~%"
          (asdf:component-version (asdf:find-system :lparallel)) cpus)
  ;; kernel creation, timed on its own (rayon creates its pool lazily too)
  (let ((t0 (get-internal-real-time)))
    (setf lparallel:*kernel* (lparallel:make-kernel cpus))
    (format t "~34A ~D ms~%~%" "make-kernel" (ms-since t0)))
  (dolist (k (list cpus 256))
    (bench (format nil "pmap-reduce, ~D chunks" k) (v-pmap-reduce k))
    (bench (format nil "preduce + pmap, ~D chunks" k) (v-preduce-pmap k))
    (bench (format nil "futures, ~D chunks" k) (v-futures k))
    (bench (format nil "pmapcar + reduce, ~D chunks" k) (v-pmapcar k))))
