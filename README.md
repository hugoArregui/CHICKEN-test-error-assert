# CHICKEN-test-error-assert

An improved `test-error` assertion for [CHICKEN's test egg](http://api.call-cc.org/doc/test)

# Interface

```scheme
(test-error <name> <expression>)
```

Equivalent to the original `test-error` procedure from the test egg, asserts `expression` returns an error.

```scheme
(test-error <name> <expression> ((kind (property-name property-value ...)) ...))
```

Asserts `expression` results in an error, and also its properties.

# Sample

```scheme

(use (except test test-error))
(use test-error-assert)

(test-error
  (assert (> 1 0) "math is not working")
  (('exn ('message "math is not working"))))
```

# Parameters

`current-no-error-name-generator`

Generate assertion name for testing the presence of an error.

`current-error-kind-assert-name-generator`

Generate assertion name for testing the error kind.

`current-error-property-exists-assert-name-generator`

Generate assertion name for testing the presence of an error's property.

`current-error-property-value-assert-name-generator`

Generate assertion name for testing the presence of an error's property value.

`current-error-property-comparator`

Compare a property value.
