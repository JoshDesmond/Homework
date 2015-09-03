;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname hwk1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; =====Homework Assigment 1=====
;; Josh Desmond & Saahil Claypool
;; ==============================
;; Assignment instructions:
;; http://web.cs.wpi.edu/~cs1102/a15/Assignments/Hwk1/index.html
;; Homework Guidelines:
;; http://web.cs.wpi.edu/~cs1102/a15/Assignments/grading-general.html
 
;; TODOLIST:
;; Make sure variable names in functions are a-boa
;; Include function: num -> string
;; Watch the indents
;; Rename insert example
;; move delete examples all together, standardize them
;; rename patch example
 
 
;; ===============================
;; ========Data Structures========
;; ===============================
;; An insert is (make-insert String)
;; An operation that inserts a string at specific location
(define-struct insert (string))
(define INSERT-BLAH (make-insert "BLAH"))
#| Insert Template
(define (insert-fun an-insert)
  ((insert-string an-insert)...))
|#
 
;; A delete is (make-delete number)
;; A type of operation that deletes the number of characters.
;; number must be greater than or equal to zero.
(define-struct delete(number))
(define DELETE-5 (make-delete 5))
(define DELETE-0 (make-delete 0))
#| Delete Template
(define (delete-fun a-delete)
  ((delete-number a-delete)...))
|#
 
;; Operation is either an insert, or a delete
#| Operation Template
(define (operation-fun operation)
(cond [(insert? operation)... insert template here)
      [(delete? operation) ... delete template here)
|#
 
;; A patch is a (make-patch integer operation)
;; Specifies an operation, and the location (integer) where the operation is applied.
(define-struct patch (position operation))
#|
(define (patch-fun patch)
  (patch-position patch)...
  (cond [(insert? (patch-operation operation))... )
        [(delete? (patch-operation operation)) ...)
|#
(define PATCH-EXAMPLE (make-patch 4 INSERT-BLAH))
;; ===============================
;; ===============================
;; ===============================
 
;; ===============================
;; ===========Functions===========
;; ===============================
;; apply-op: operation string number -> string
;; Consumes an operation, a string, and a number
;; Produces the resulting string of applying the given operation
(define (apply-op operation string position)
  (cond [(insert? operation) (string-append 
                              (string-append (substring string 0 position) 
                                             (insert-string operation)) ;;Append the operation's string to the first splice of the document
                              (substring string position))] ;; Then append the above to the second splice of the document (or the rest of it)
        [(delete? operation)   (string-append (substring string 0 position) ;;Append the beginning of the string
                                              (substring string (+ position ;; To the second splice of the string
                                                                   (delete-number operation))))]))
;; Test cases:
(check-expect (apply-op INSERT-BLAH "abcdefg" 4) "abcdBLAHefg")
(check-expect (apply-op (make-insert "Dopa") "DopaSeratonin" 4) "DopaDopaSeratonin")
(check-expect (apply-op DELETE-5 "123456789" 3) "1239")
 
;; apply-patch: patch string -> string
;; Consumes a patch and a string
;; Produces the string resulting from applying the patch to the string
;; Assumes given string is long enough for the patch
(define (apply-patch a-patch string)
  (apply-op (patch-operation a-patch) string (patch-position a-patch)))
 
(check-expect (apply-patch PATCH-EXAMPLE "123456789") "1234BLAH56789")


;; Overlap?: patch patch -> boolean
;; consumes 2 patches and determines if they overlap
(define (overlap? patchA patchB)
  (cond [(and (insert? (patch-operation patchA))
              (insert? (patch-operation patchB)))
         (insertion-overlap? patchA patchB)]
        [(and (delete? (patch-operation patchA))
              (delete? (patch-operation patchB)))
         (deletion-overlap? patchA patchB)]
        [else(mixed-overlap? patchA patchB)]))
;; Test cases for overlap?
(check-expect (overlap? (make-patch 4 INSERT-BLAH)(make-patch 4 INSERT-BLAH)) true) 
(check-expect (overlap? (make-patch 4 DELETE3)(make-patch 4 DELETE3)) true) 
(check-expect (overlap? (make-patch 4 INSERT-BLAH) (make-patch 4 DELETE3)) false)
(check-expect (overlap? (make-patch 4 INSERT-BLAH) (make-patch 4 INSERT-BLAH)) true)



;; helper functions
;; Insertions-overlap?: patch patch -> boolean
;; Both patches must have insertions as operations determines if they overlap 
(patch-position PATCH-EXAMPLE)
(define (insertion-overlap? patchA patchB)
  (= (patch-position patchA)
     (patch-position patchB)))


(check-expect (insertion-overlap? (make-patch 4 INSERT-BLAH)
                                  (make-patch 4 INSERT-BLAH )) true)

(check-expect (insertion-overlap? (make-patch 8 INSERT-BLAH)
                                  (make-patch 0 INSERT-BLAH )) false)



;; getRight: patch (deletion) -> num
;; gets a deletion patch and determines right bound of range
(check-expect (getRight (make-patch 4 (make-delete 3))) 7)
(define (getRight a-patch)
  (+ (delete-number(patch-operation a-patch))
     (patch-position a-patch)))


;; Deletion-overlap?: patch patch -> boolean
;; both patches myust have deletions as operations, determines if these overlap
(define (deletion-overlap? patchA patchB)

  (  and (<= (patch-position patchA) (getRight patchB))
          (>= (getRight patchA) (patch-position patchB))))
                                       
     (define DELETE3 (make-delete 3))

     (check-expect (deletion-overlap? (make-patch 5 DELETE3)
                                      (make-patch 0 DELETE3))
                   false)
     (check-expect (deletion-overlap? (make-patch 0 DELETE3)
                                      (make-patch 0 DELETE3))
                   true)
     (check-expect (deletion-overlap? (make-patch 2 DELETE3)
                                      (make-patch 0 DELETE3))
                   true)

(check-expect (deletion-overlap? (make-patch 0 DELETE3)
                                 (make-patch 3 DELETE3))
              true)

;; Mixed-overlap?: patch patch -> boolean
;; Consumes a patch and a patch
;; Produces a boolean
;; Determines if the two given patches are compatible or if they overlap.
;; patches must be of mixed type. The order of the type does not matter
(define (mixed-overlap? patchA patchB)
  (cond [(delete? (patch-operation patchA))
         (mixed-overlap? patchB patchA)]
        [else (cond [(<= (patch-position patchA) (patch-position patchB)) false]
                    [else (< (patch-position patchA) (getRight patchB))])]))
 
;; Test one, insertion is before deletion -> false
(check-expect (mixed-overlap? (make-patch 0 INSERT-BLAH) (make-patch 2 DELETE-2)) false)
;; Test two, insertion is in the middle of deletion -> true
(check-expect (mixed-overlap? (make-patch 2 INSERT-BLAH) (make-patch 0 DELETE-5)) true)
;; Test three, insertion is after the deletion -> false
(check-expect (mixed-overlap? (make-patch 10 INSERT-BLAH) (make-patch 0 DELETE-5)) false)
;; Test four, insertion is before deletion in reversed order -> false
(check-expect (mixed-overlap? (make-patch 5 DELETE-2) (make-patch 1 INSERT-BLAH)) false)
;; Test five, insertion is in the middle of deletion in reversed order -> true
(check-expect (mixed-overlap? (make-patch 4 DELETE-5) (make-patch 6 INSERT-BLAH)) true)
 
(define DELETE-2 (make-delete 2))

;; merge: string patch1 patch2 -> string (or boolean)
;; Consumes two patches and a string
;; Produces a string of the result, or false if the patches are not compatible
(define (merge doc-string patch1 patch2)
  (cond [(overlap? patch1 patch2) false]
        [else (cond [(> (patch-position patch1) (patch-position patch2)) (merge doc-string patch2 patch1)]
                    [else (apply-patch patch1 (apply-patch patch2 doc-string))])]))

;; Test Cases
(define TEST-DOC "abcdefg")
(define DEL-efg (make-patch 4 DELETE3))
(define DEL-bcd (make-patch 1 DELETE3))
(define INS-x (make-insert "x"))
;; Test case 1, successful merge, delete efg, insert x at b
(check-expect (merge TEST-DOC DEL-efg (make-patch 2 INS-x)) "abxcd")
;; Test case 2, successful merge, insert x at b, delete efg
(check-expect (merge TEST-DOC (make-patch 2 INS-x) DEL-efg) "abxcd")
;; Test case 3, unsuccessful merge, insert x at f, delete efg
(check-expect (merge TEST-DOC (make-patch 6 INS-x) DEL-efg) false)
;; Test case 4, successful merge, insert x at f, delete bcd
(check-expect (merge TEST-DOC (make-patch 6 INS-x) DEL-bcd) "aefxg")
;; Test case 5, successful merge, delete bcd, delete efg
(check-expect (merge TEST-DOC DEL-bcd DEL-efg) "a")
;; Test case 6, successful merge, delete efg, delete bcd
(check-expect (merge TEST-DOC DEL-efg DEL-bcd) "a")
;; Test case 7, successful insert x at b, insert x at g
(check-expect (merge TEST-DOC (make-patch 2 INS-x) (make-patch 7 INS-x)) "abxcdefgx")
;; Test case 8, unsuccessful merge, delete efg, delete g
(check-expect (merge TEST-DOC DEL-efg (make-patch 7 (make-delete 1))) false)
;; Test case 9, unsuccessful merge, delete cdef, delete bc
(check-expect (merge TEST-DOC (make-patch 3 DELETE3)(make-patch 2 (make-delete 2))) false)

    
     
     #| Question 6.)
In the previous question, we returned false in the event of an overlap.
Another option might have been to just return the original (unmerged)
string. What are the advantages of returning false instead of the original
string in the event of overlap?

 Returning false is useful tactic because it allows the user of the program to clearly know that something did not work with the patches they attempted to apply.
Also, the false that is returned in by the overlap? more clearly answers the question "do these two patches conflict" than the returning the original string
 
|#
;; replace 176 with current string length
(define patch1 (make-patch (158) (make-delete 4)))
(define patch2 (make-patch (158) (make-insert "it's totally")))
(define patch3 (make-patch (93) (make-delete 4)))
(define patch4 (make-patch (93) (make-insert "it is")))
(define patch5 (make-patch (89) (make-delete 4)))
(define patch6 (make-patch (79) (make-delete 8)))
(define patch7 (make-patch (79) (make-insert "golly")))
(define patch8 (make-patch (46) (make-delete 2)))
(define patch9 (make-patch (46) (make-insert "the")))
(define patch10 (make-patch (32) (make-insert "over there ")))
(define patch11 (make-patch (19) (make-delete 6)))
(define patch12 (make-patch (19)(make-insert "that")))

(define original "Hamlet: Do you see yonder cloud that's almost in shape of a camel?Polonius: By the mass, and 'tis like a camel, indeed.[...]Hamlet: Or like a whale?Polonius: Very like a whale.")

(define alternative "Hamlet: Do you see the cloud over there that's almost the shape of a camel?Polonius: By golly, it is like a camel, indeed.[...]Hamlet: Or like a whale?Polonius: It's totally like a whale.")
original
(apply-patch patch2(apply-patch patch1 original))

#|

Question 7. 
Consider the following quotation from Hamlet and an alternative in more modern English:

*** Original ***
Hamlet: Do you see yonder cloud that's almost in shape of a camel?
Polonius: By the mass, and 'tis like a camel, indeed.
[...]
Hamlet: Or like a whale?
Polonius: Very like a whale. (176 characters)

*** Alternative ***
Hamlet: Do you see the cloud over there that's almost the shape of a camel?
Polonius: By golly, it is like a camel, indeed.
[...]
Hamlet: Or like a whale?
Polonius: It's totally like a whale.
Define constants for the patches needed to convert the first quotation to the second. Treat each of the two quotations as a single string (you do not need to capture the newlines). Then write a function modernize that consumes a string and applies all of those patches to the string. Test your function on the original Hamlet excerpt. [Acknowledgement: This example is a subset of the one in Neil Fraser's explanation of the patch utility.]

 
    back to front, delete before insert where possible 
(define patch1 (make-patch (- 176 18) (make-delete 4)))
(define patch2 (make-patch (- 176 14) (make-insert "it's totally")))
(define patch3 (make-patch (- 176 91) (make-delete 4)))
(define patch4 (make-patch (- 176 87) (make-insert "it is")))
(define patch5 (make-patch (- 176 96) (make-delete 4)))
(define patch6 (make-patch (- 176 102) (make-delete 8)))
(define patch7 (make-patch (- 176 94) (make-insert "golly")))
(define patch8 (make-patch (- 176 132) (make-delete 2)))
(define patch9 (make-patch (- 176 130) (make-insert "the")))
(define patch10 (make-patch (- 176 147) (make-insert "over there ")))
(define patch11 (make-patch (- 176 171) (make-delete 6)))
(define patch12 (make-patch (- 176 165)(make-insert "that")))



Evaluate each of the following expressions by hand (use the rules covered in class, which match those of Beginner level). Show every step. In each expression, indicate the subexpression that is evaluated to obtain the next expression. For example:
        (sqrt (+ (* 3 3) (* 4 4)))
                 ^^^^^^^
      = (sqrt (+ 9 (* 4 4)))
                   ^^^^^^^
      = (sqrt (+ 9 16))
              ^^^^^^^^
      = (sqrt 25)
        ^^^^^^^^^
      = 5
If an expression would result in an error, show all of the steps up to the error, then indicate the error message you'd get (error messages don't need to be verbatim, as long as they convey the right kind of error). You can use the Stepper to check your answers, but do the problem manually first to make sure you understand how Racket works.
 
8: (/ (- (* 9 3) (double 'a)) 2) where double is defined as (define (double n) (* n 2))
Dez
9: (or (< 5 2) (and (= 15 (- 18 3)) (> 8 4)))
 
 
(or (< 5 2) (and (= 15 (- 18 3)) (> 8 4)))
     ^^^^^^
(or false (and (= 15 (- 18 3)) (> 8 4)))
                     ^^^^^^^^^
(or false (and (= 15 15) (> 8 4)))
                ^^^^^^^         
(or false (and true (> 8 4)))
                     ^^^^^^^
(or false (and true true))
            ^^^^^^^^^^^^
(or false true)
^^^^^^^^^^^^^^
true
 
 
 
 
 
 
10: (and (+ 5 -1) false)
Dez
11: (apply-patch 'remove "this is a test string") [use your own apply-patch program from this assignment]
Saa
Debugging Racket Programs
 
For each of the following DrRacket error messages (from Beginner language level), describe what code that produces this error message would look like and provide a small illustrative example of code that would yield this error. Your description should not simply restate the error message!
 
12: cond: expected a clause with a question and answer, but found a clause with only one part
Josh
13: x: this variable is not defined
Saa
14: function call: expected a function after an open parenthesis, but found a number
Josh

|#
     

