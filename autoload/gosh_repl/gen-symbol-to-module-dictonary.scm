(define default-modules (all-modules))

(use srfi-1)
(use srfi-13)
(use file.util)

(define-constant gen-file-name "sym-to-module")

(define (valid-exports exports)
  (filter
    (lambda (sym)
      (let* ([str-sym (symbol->string sym)]
             [first-ch (string-ref  str-sym 0)])
        (not (or 
               (eq? first-ch #\%)
               (#/\s/ str-sym)
               (#/^\*\S*\*$/ str-sym)
               (#/^G\d{3}$/ str-sym)))))
    exports))

(define (add-remove-supecial-module module-map)
  (append
    (remove
      (lambda (m) (eq? (car m) 'user))
      module-map)
    (filter
      identity
      (append-map
        (lambda (s)
          (library-map 
            s 
            (lambda (m p) 
              (guard (e [else #f])
                (eval `(require ,(module-name->path m)) 'gauche)
                (cons
                  m
                  (valid-exports (module-exports (find-module m))))))))
        '(* *.* *.*.* *.*.*.* *.*.*.*.*)))))

(define (parent-module? module parent)
  (any
    (pa$ eq? parent)
    (map
      module-name
      (module-precedence-list (find-module module)))))

(define (module-map-to-hash-table module-map)
  (let1 table (make-hash-table)
    (for-each (lambda (m)
        (for-each
          (lambda (s)
            (unless (and (hash-table-exists? table s)
                      (parent-module? (car m) (hash-table-get table s)))
              (hash-table-put! table s (car m))))
          (cdr m)))
      module-map)
    table))

(define symbol-table 
  (module-map-to-hash-table (add-remove-supecial-module '())))

(with-output-to-file
  gen-file-name
  (lambda ()
    (print "(define-constant %s->m% (make-hash-table))")
    (for-each (lambda (key)
      (print #`"(hash-table-put! %s->m% ',key ',(hash-table-get symbol-table key))"))
      (hash-table-keys symbol-table))))

