(module test-error-assert
  (test-error
    default-error-property-comparator
    default-no-error-name-generator
    default-error-kind-assert-name-generator
    default-error-property-exists-assert-name-generator
    default-error-property-value-assert-name-generator
    current-error-property-comparator
    current-no-error-name-generator
    current-error-kind-assert-name-generator
    current-error-property-exists-assert-name-generator
    current-error-property-value-assert-name-generator)

  (import chicken scheme)
  (import-for-syntax matchable chicken)
  (use srfi-13)
  (use (rename (only test test-error current-test-comparator) (test-error original-test-error)))

  (define (default-no-error-name-generator assertion-name)
    (format "~a error expected" assertion-name))

  (define (default-error-kind-assert-name-generator assertion-name kind)
    (format "~a assert condition kind is ~a" assertion-name kind))

  (define (default-error-property-exists-assert-name-generator assertion-name kind property-name)
    (format "~a (~a) property ~a exists" assertion-name kind property-name))

  (define (default-error-property-value-assert-name-generator assertion-name kind property-name)
    (format "~a (~a) property ~a has value" assertion-name kind property-name))

  (define (default-error-property-comparator kind property-name expected-value value)
    (if (eq? property-name 'message)
      (string-contains value expected-value)
      ((current-test-comparator) expected-value value)))

  (define current-no-error-name-generator
    (make-parameter default-no-error-name-generator))
  (define current-error-kind-assert-name-generator
    (make-parameter default-error-kind-assert-name-generator))
  (define current-error-property-exists-assert-name-generator
    (make-parameter default-error-property-exists-assert-name-generator))
  (define current-error-property-value-assert-name-generator
    (make-parameter default-error-property-value-assert-name-generator))
  (define current-error-property-comparator 
    (make-parameter default-error-property-comparator))

  (define-for-syntax (unroll-condition-property-assertions r name kind property-assertions kind-info)
    (let ((%assq                   (r 'assq))
          (%cadr                   (r 'cadr))
          (%test                   (r 'test))
          (%begin                  (r 'begin))
          (%test-assert            (r 'test-assert))
          (%p-comparator           (r 'current-error-property-comparator))
          (%pexists-name-generator (r 'current-error-property-exists-assert-name-generator))
          (%pvalue-name-generator  (r 'current-error-property-value-assert-name-generator)))
      (map (match-lambda
             ((p-name p-value)
              `(,%begin
                 (,%test-assert ((,%pexists-name-generator) ,name ,kind ,p-name) (,%assq ,p-name ,kind-info))
                 (,%test-assert ((,%pvalue-name-generator) ,name ,kind ,p-name)
                                ((,%p-comparator) ,kind ,p-name ,p-value (,%cadr (,%assq ,p-name ,kind-info))))))
             (any
               (assert #f "invalid property assertion" any)))
           property-assertions)))

  (define-for-syntax (unroll-condition-assertions r name assertions condition-info)
    (let ((%assq                (r 'assq))
          (%begin               (r 'begin))
          (%kind-info           (r 'kind-info))
          (%let                 (r 'let))
          (%cdr                 (r 'cdr))
          (%test-assert         (r 'test-assert))
          (%kind-name-generator (r 'current-error-kind-assert-name-generator)))
      (map (match-lambda
             ((kind . property-assertions)
              `(,%begin
                 (,%let ((,%kind-info (,%assq ,kind ,condition-info)))
                        (,%test-assert ((,%kind-name-generator) ,name ,kind) ,%kind-info)
                        ,@(unroll-condition-property-assertions r name kind property-assertions `(,%cdr ,%kind-info)))))
             (any
               (assert #f "invalid assertion" any)))
           assertions)))

  (define-syntax test-error
    (er-macro-transformer
      (lambda (x r c)
        (let ((%original-test-error     (r 'original-test-error))
              (%condition-case          (r 'condition-case))
              (%condition->list         (r 'condition->list))
              (%begin                   (r 'begin))
              (%test-assert             (r 'test-assert))
              (%e                       (r 'e))
              (%no-error-name-generator (r 'current-no-error-name-generator)))
          (match x
            ((_ name expression)
             `(,%original-test-error ,expression))
            ((_ name expression properties)
             `(,%condition-case (,%begin
                                  ,expression
                                  (,%test-assert ((,%no-error-name-generator) ,name) #f))
                                (,%e ()
                                     ,@(unroll-condition-assertions r name properties `(,%condition->list ,%e))))))))))
  )
