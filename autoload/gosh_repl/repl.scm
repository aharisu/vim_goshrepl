
(define %find-module% #f)
(let1 loaded #f
  (set! %find-module% 
    (lambda (str-sym) 
      (if *enable-auto-use*
        (begin
          (unless loaded
            (set! loaded #t)
            (load "sym-to-module" :ignore-coding #t))
          (hash-table-get %s->m% (string->symbol str-sym) #f))
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
                    (%repl-eval% e env)) ;retry eval
                  err)))] ;throw error
           [else err]) ;throw error
    (eval e env)))

(read-eval-print-loop 
  #f 
  %repl-eval%
  (lambda args (for-each (lambda (e) (write e)(newline)) args)(flush))
  (lambda () (display "gosh> ")(flush)))
