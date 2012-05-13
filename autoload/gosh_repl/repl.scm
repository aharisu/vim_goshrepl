(define *%history%* '())

(define %load-sym-to-module%
  (let1 loaded #f
    (lambda ()
      (unless loaded
        (set! loaded #t)
        (load "sym-to-module" :ignore-coding #t)))))

(define %find-module% 
  (let1 loaded #f
    (lambda (str-sym) 
      (if *enable-auto-use*
        (begin
          (%load-sym-to-module%)
          (hash-table-get %s->m% str-sym #f))
        #f))))

(define (%repl-eval% e env)
  (guard (err 
           [(and (<error> err)
              (#/^unbound variable: (.*)/ (slot-ref err 'message)))
            =>
            (lambda (m) 
              (let1 mod (%find-module% (m 1))
                (if mod
                  (begin
                    (eval `(use ,mod) env) ;auto use
                    (print "repl> auto use of " (x->string mod) " for " (m 1))
                    (%repl-eval% e env)) ;retry eval
                  err)))] ;throw error
           [else err]) ;throw error
    (eval e env)))

(define (recent idx)
  (if (< idx (length *%history%*))
    (last (take (reverse *%history%*) (+ idx 1)))))

(define (latest)
  (if (pair? *%history%*)
    (car *%history%*)))

(define (history :optional (len 10))
  (let* ([history-length (length *%history%*)]
         [history-start (- history-length (min history-length len))])
    (let loop ([history (reverse (take *%history%* (min history-length len)))]
               [idx 0])
      (print (format "[~4d] ~a" (+ history-start idx) (car history)))
      (unless (null? (cdr history))
        (loop (cdr history) (+ idx 1))))
    (values)))

(define which-module
  (let1 loaded #f
    (lambda (item :key (match 'submatch))
      (let ([matcher (cond 
                       [(or (symbol? item) (string? item))
                        (let ([substr (x->string item)]
                              [comp (if (eq? match 'strict) string=? string-scan)])
                          (lambda (name) (comp name substr)))]
                       [(is-a? item <regexp>) 
                        (let1 comp (if (eq? match 'strict)
                                     (lambda (regexp str)
                                       (let1 m (rxmatch regexp str)
                                         (if m (string=? (m 0) str) #f)))
                                     rxmatch)
                          (lambda (name) (comp item name)))]
                       [else (error "Bad object for item: " item)])]
            [result '()])

        (define (found module symbol)
          (set! result
            (cons (format #f "~30a (~a)~%" symbol module)
                  result)))

        ;;load defualt module symbols
        (unless loaded
          (set! loaded #t)
          (load "def-sym-to-module"))
        ;;search from defualt module
        (for-each
          (lambda (mod.sym-list)
            (for-each
              (lambda (str-sym)
                (when (matcher str-sym)
                  (found (car mod.sym-list) str-sym)))
              (cdr mod.sym-list)))
          %d.m->s%)

        ;;load library module
        (%load-sym-to-module%)
        ;;search from library module
        (for-each
          (lambda (str-sym)
            (when (matcher str-sym)
              (found (hash-table-get %s->m% str-sym) str-sym)))
          (hash-table-keys %s->m%))

        ;;output result
        (for-each display (sort result))

        ;;return value
        (values)))))

(read-eval-print-loop 
  #f 
  %repl-eval%
  (lambda args 
    (for-each 
      (lambda (e)
        (if (<condition> e)
          (report-error e)
          (begin
            (unless (undefined? e)
              (push! *%history%* e))
            (write e)(newline))))
      args)
    (flush))
  (lambda () (display "gosh> ")(flush)))

