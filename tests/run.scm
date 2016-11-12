(use (except test test-error) test-error-assert irregex srfi-1)

(define (match s regex)
  (irregex-match `(posix-string ,regex) s))

(let* ((output (call-with-output-string
                 (lambda (s)
                   (parameterize ((current-output-port s))
                                 (test-error "invalid" (assert (< 0 1)) (('exn ('message ""))))))))
       (lines  (string-split output "\n")))
  (test-assert "should fail if no error"
               (match (first lines) "invalid error expected.+\\[ FAIL\\]")))

(let* ((output (call-with-output-string
                 (lambda (s)
                   (parameterize ((current-output-port s))
                                 (test-error "invalid" (assert (> 0 1)) (('exn2)))))))
       (lines  (string-split output "\n")))
  (test-assert "assert condition kind"
               (match (first lines) "invalid assert condition kind is exn2.+\\[ FAIL\\]")))

(let* ((output (call-with-output-string
                 (lambda (s)
                   (parameterize ((current-output-port s))
                                 (test-error "invalid" (assert (> 0 1)) (('exn ('message ""))))))))
       (lines  (string-split output "\n")))

  (test-assert "assert condition kind"
               (match (first lines) "invalid assert condition kind is exn.+\\[ PASS\\]"))

  (test-assert "assert condition property existence"
               (match (second lines) "invalid \\(exn\\) property message exists.+\\[ PASS\\]"))

  (test-assert "assert condition property value"
               (match (third lines) "invalid \\(exn\\) property message has value.+\\[ FAIL\\]")))

(let* ((output (call-with-output-string
                 (lambda (s)
                   (parameterize ((current-output-port s))
                                 (test-error "invalid" (assert (> 0 1)) (('exn ('message ""))))))))
       (lines  (string-split output "\n")))

  (test-assert "assert condition kind"
               (match (first lines) "invalid assert condition kind is exn.+\\[ PASS\\]"))

  (test-assert "assert condition property existence"
               (match (second lines) "invalid \\(exn\\) property message exists.+\\[ PASS\\]"))

  (test-assert "assert condition property value"
               (match (third lines) "invalid \\(exn\\) property message has value.+\\[ FAIL\\]")))

(let* ((output (call-with-output-string
                 (lambda (s)
                   (parameterize ((current-output-port s))
                                 (test-error "invalid"
                                             (signal
                                               (make-composite-condition
                                                 (make-property-condition 'not-a-pair 'value 1)
                                                 (make-property-condition 'exn 'value 2)))
                                             (('exn ('value 2))
                                              ('not-a-pair ('value 1))))))))
       (lines  (string-split output "\n")))

  (test-assert "assert first condition kind"
               (match (first lines) "invalid assert condition kind is exn.+\\[ PASS\\]"))

  (test-assert "assert first kind condition property existence"
               (match (second lines) "invalid \\(exn\\) property value exists.+\\[ PASS\\]"))

  (test-assert "assert first kind condition property value"
               (match (third lines) "invalid \\(exn\\) property value has value.+\\[ PASS\\]"))

  (test-assert "assert second condition kind"
               (match (fourth lines) "invalid assert condition kind is not-a-pair.+\\[ PASS\\]"))

  (test-assert "assert second kind condition property existence"
               (match (fifth lines) "invalid \\(not-a-pair\\) property value exists.+\\[ PASS\\]"))

  (test-assert "assert second kind condition property value"
               (match (sixth lines) "invalid \\(not-a-pair\\) property value has value.+\\[ PASS\\]")))

(test-exit)
