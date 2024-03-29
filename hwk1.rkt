;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname hwk1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; Josh Desmond
;; Saahil Claypool


;; =====Homework Assigment 1=====
;; Josh Desmond & Saahil Claypool
;; ==============================
;; Assignment instructions:
;; http://web.cs.wpi.edu/~cs1102/a15/Assignments/Hwk1/index.html
;; Homework Guidelines:
;; http://web.cs.wpi.edu/~cs1102/a15/Assignments/grading-general.html
 
 
;; ===============================
;; ========Data Structures========
;; ===============================
;; ~~~~~~~~~~~~insert~~~~~~~~~~~~~~~~~~
;; An insert is (make-insert String)
;; An insert is a type of operation (see "operation" data structure)
;; which specifies to insert the given string.
(define-struct insert (string))
(define INSERT-BLAH (make-insert "BLAH"))
(define INSERT-HELLO (make-insert "HELLO"))
#| Insert Template
(define (insert-fun an-insert)
  ((insert-string an-insert)...))
|#
 
;; ~~~~~~~~~~~delete~~~~~~~~~~~~~
;; A delete is (make-delete number)
;; A delete is a type of operation that deletes the specified number of characters.
;; number must be greater than or equal to zero.
;; number specifies the number of characters to delete (with 0 deleting no characters).
(define-struct delete(number))
(define DELETE-5 (make-delete 5))
(define DELETE-0 (make-delete 0))
(define DELETE-2 (make-delete 2))
#| Delete Template
(define (delete-fun a-delete)
  ((delete-number a-delete)...))
|#

;; ~~~~~~~~~~~operation~~~~~~~~~~~~~~~
;; Operation is either an insert, or a delete
#| Operation Template
(define (operation-fun operation)
(cond [(insert? operation)... insert template here)
      [(delete? operation) ... delete template here)
|#
 
;; ~~~~~~~~~~~~~~~patch~~~~~~~~~~~~~~~~
;; A patch is a (make-patch integer operation)
;; Specifies an operation, and the location (integer) where the operation is applied.
;; position specifies the location in the document where the given operation will occur.
;; position 0 would specify to insert text before any characters, or to delete the first character.
(define-struct patch (position operation))
#|
(define (patch-fun patch)
  (patch-position patch)...
  (cond [(insert? (patch-operation operation))... )
        [(delete? (patch-operation operation)) ...)
|#
(define PATCH-EXAMPLE (make-patch 4 INSERT-BLAH))
(define PATCH-APPEND-X (make-patch 0 (make-insert "x")))
(define PATCH-DELETION (make-patch 3 (make-delete 4)))
 


;; ===============================
;; ===========Functions===========
;; ===============================
;; ~~~~~~~~~apply-op~~~~~~~~~~~~~~
;; apply-op: operation string number -> string
;; Consumes an operation, a string, and a number
;; Produces the resulting string of applying the given operation
;; Where string is the document to which the operation is being applied
;; position is the location where the operation which be applied 
;;  (such that 0 specifies to delete the first character, or append to the beggining of the string)
;; operation is the operation to be applied.
(define (apply-op operation string position)
  (cond [(insert? operation) (string-append 
                              (string-append (substring string 0 position) 
                                             (insert-string operation)) ;;Append the operation's string to the first splice of the document
                              (substring string position))] ;; Then append the above to the second splice of the document (or the rest of it)
        [(delete? operation)   (string-append (substring string 0 position) ;;Append the beginning of the string
                                              (substring string (+ position ;; To the second splice of the string
                                                                   (delete-number operation))))]))
;; apply-op: Test Cases
(check-expect (apply-op INSERT-BLAH "abcdefg" 4) "abcdBLAHefg")
(check-expect (apply-op (make-insert "Dopa") "DopaSeratonin" 4) "DopaDopaSeratonin")
(check-expect (apply-op DELETE-5 "123456789" 3) "1239")
;; (Note: More complete testing is covered by "apply-patch")

 
;; ~~~~~~~~~~apply-patch~~~~~~~~~~~~~~
;; apply-patch: patch string -> string
;; Consumes a patch and a string
;; Produces the string resulting from applying the patch to the string
;; Where string is the document to which the patch is being applied
;; and patch is any patch
;; Assumes the given string is long enough for the patch
(define (apply-patch a-patch string)
  (apply-op (patch-operation a-patch) string (patch-position a-patch)))
 
;; apply-patch: Test Cases
;; Test 1, apply an insert
(check-expect (apply-patch PATCH-EXAMPLE "123456789") "1234BLAH56789")
;; Test 2, apply a deletion
(check-expect (apply-patch (make-patch 3 DELETE-5) "abcdefgh") "abc")
;; Test 3, apply an empty deletion
(check-expect (apply-patch (make-patch 2 DELETE-0) "abcd") "abcd")
;; Test 4, append x to beginning
(check-expect (apply-patch PATCH-APPEND-X "abcde") "xabcde")
;; Test 5, delete the first character
(check-expect (apply-patch (make-patch 0 (make-delete 1)) "abcd") "bcd")

;; ~~~~~~~~~overlap?~~~~~~~~~~~~~~~~
;; overlap?: patch patch -> boolean
;; consumes two patches
;; produces a boolean determing whether the patches overlap
;; returns true if they do overlap (or if the patches can't be merged)
;; Two patches overlap if:
;;  - Two insertions occur at the same location
;;  - The range of two deletions overlap
;;  - If an insertion occurs within the range of a deletion
(define (overlap? patchA patchB)
  (cond [(and (insert? (patch-operation patchA)) ;; If they are both inserts
              (insert? (patch-operation patchB)))
         (insertion-overlap? patchA patchB)] ;; Call insertion-overlap
        [(and (delete? (patch-operation patchA)) ;; if they are both deletions
              (delete? (patch-operation patchB)))
         (deletion-overlap? patchA patchB)] ;; Check if deletion overlap
        [else (mixed-overlap? patchA patchB)])) ;; Else means patchA and patchB are of mixedType. Order does not matter.

;; overlap?: Test Cases
;; Test 1, two overlapping insertions -> true
(check-expect (overlap? (make-patch 4 INSERT-BLAH)(make-patch 4 INSERT-BLAH)) true)
;; Test 2, two overlapping deletions -> true
(check-expect (overlap? (make-patch 4 DELETE3)(make-patch 4 DELETE3)) true) 
;; Test 3, a deletion and an insertion both at same position -> false
(check-expect (overlap? (make-patch 4 INSERT-BLAH) (make-patch 4 DELETE3)) false)
;; Test 4,  an insertion and deletion that don't overlap
(check-expect (overlap? (make-patch 2 INSERT-BLAH) (make-patch 5 DELETE-5)) false)
;; Test 5, a deletion and an insertion that don't overlap
(check-expect (overlap? (make-patch 5 DELETE-5) (make-patch 2 INSERT-BLAH)) false)


;; ~~~~~~~~~~insertions-overlap?~~~~~~~~~~~~~~~~
;; insertions-overlap?: patch patch -> boolean
;; Consumes two patches with insertions as its operation
;; Produces a boolean indicating whether patchA and patchB overlap
;; Both patches must have insertions as operations
(define (insertion-overlap? patchA patchB)
  (= (patch-position patchA)
     (patch-position patchB)))

;; Insertions-overlap?: Test Cases
(check-expect (insertion-overlap? (make-patch 4 INSERT-BLAH)
                                  (make-patch 4 INSERT-BLAH )) true)
(check-expect (insertion-overlap? (make-patch 8 INSERT-BLAH)
                                  (make-patch 0 INSERT-BLAH )) false)
(check-expect (insertion-overlap? (make-patch 4 INSERT-BLAH)
                                  (make-patch 6 (make-insert "x"))) false)


;; ~~~~~~~~~~~deletion-overlap?~~~~~~~~~~~~
;; deletion-overlap?: patch patch -> boolean
;; both patches must have deletions as operations
;; returns true if the patches overlap
(define (deletion-overlap? patchA patchB)
  (and (< (patch-position patchA) (getRight patchB))
          (> (getRight patchA) (patch-position patchB))))
    
;; delete-overlap?: Test Cases
(define DELETE3 (make-delete 3))
(check-expect (deletion-overlap? (make-patch 5 DELETE3)
                                 (make-patch 0 DELETE3)) false)
(check-expect (deletion-overlap? (make-patch 0 DELETE3)
                                 (make-patch 0 DELETE3)) true)
(check-expect (deletion-overlap? (make-patch 2 DELETE3)
                                 (make-patch 0 DELETE3)) true)
(check-expect (deletion-overlap? (make-patch 0 DELETE3)
                                 (make-patch 3 DELETE3)) false)
(check-expect (deletion-overlap? (make-patch 3 DELETE3)
                                 (make-patch 0 DELETE3)) false)
(check-expect (deletion-overlap? (make-patch 0 DELETE-0)
                                 (make-patch 0 DELETE-0)) false)


;; ~~~~~~~~~~getRight~~~~~~~~~~~~~
;; getRight: patch -> number
;; Consumes a patch with deletion as its operation
;; Returns the position where the deletion ends
;; a-patch must have a deletion as its operation.
(define (getRight a-patch)
  (+ (delete-number(patch-operation a-patch))
     (patch-position a-patch)))
;; getRight: Test Cases
(check-expect (getRight (make-patch 4 (make-delete 3))) 7)
(check-expect (getRight (make-patch 2 DELETE-0)) 2)
(check-expect (getRight (make-patch 2 DELETE-5)) 7)

;; ~~~~~~~~~~~mixed-overlap?~~~~~~~~~~~~~~~
;; mixed-overlap?: patch patch -> boolean
;; Consumes a patch and a patch
;; Produces a boolean
;; Determines if the two given patches are compatible or if they overlap.
;; Returns true if the patches overlap.
;; One patch must be have insert as its operation, and the other must have
;; a delete as its operation. The order of the type does not matter
(define (mixed-overlap? patchA patchB)
  (cond [(delete? (patch-operation patchA))
         (mixed-overlap? patchB patchA)] ;; Recursively call self with flipped inputs.
        [(delete? (patch-operation patchB)) (cond [(<= (patch-position patchA) (patch-position patchB)) false]
                    [else (< (patch-position patchA) (getRight patchB))])]))
 
;; mixed-overlap?: Test Cases
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
;; test six, insertion is at the same position of an empty delete -> false
(check-expect (mixed-overlap? (make-patch 4 INSERT-BLAH) (make-patch 4 DELETE-0)) false)

;; ~~~~~~~~~~~~merge~~~~~~~~~~~
;; merge: string patch patch -> string, or a boolean
;; Consumes two patches and a string
;; Produces a string of the result, or false if the patches are not compatible
;; This function takes the two given patches and applies them to a document
;; The order of the given patches will not effect output, i.e: (merge "s" a b) = (merge "s" b a)
;; If a deletion and insertion are applied at the same location, deletion will be applied first
(define (merge doc-string patch1 patch2)
  (cond [(overlap? patch1 patch2) false] ;; return false if the patches overlap
        [(not (overlap? patch1 patch2)) 
         (cond [(> (patch-position patch1) (patch-position patch2)) ;; if the patches are in the wrong order
                (merge doc-string patch2 patch1)] ;; then call merge with the patches in fliped position
               [(overlap-insert-then-delete? patch1 patch2) ;; in this special case
                (merge doc-string patch2 patch1)] ;; then merge the two patches in reverse order     
               [else (apply-patch patch1 (apply-patch patch2 doc-string))])])) ;; otherwise, apply both patches

;; merge: Test Cases
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
(check-expect (merge TEST-DOC DEL-efg (make-patch 6 (make-delete 1))) false)
;; Test case 9, unsuccessful merge, delete cdef, delete bc
(check-expect (merge TEST-DOC (make-patch 3 DELETE3)(make-patch 2 (make-delete 2))) false)
;; Test case 10, successful merge, deletion and insertion at same position
(check-expect (merge TEST-DOC (make-patch 3 DELETE3) (make-patch 3 INS-x)) "abcxg")
;; Test case 11, successful merge, insertion and deletion at same position
(check-expect (merge TEST-DOC (make-patch 3 INS-x) (make-patch 3 DELETE3)) "abcxg")


;; overlap-insert-then-delete?: patch patch -> boolean
;; helper function for merge
;; Returns true if patch1 is an insert, and patch2 is a delete, and both patches start at the same position
(define (overlap-insert-then-delete? patch1 patch2)
  (and (and (= (patch-position patch1) (patch-position patch2)) ;; if the patches are at the same position
            (delete? (patch-operation patch1))) ;; and patch 1 is a deletion
       (insert? (patch-operation patch2)))) ;; and patch2 is an insertion )

;; Test cases not written because this is a refactored helper function that is tested within "merge" 

;; ===============================
;; =======Homework Problems=======
;; ===============================
     #| Question 6.)
In the previous question, we returned false in the event of an overlap.
Another option might have been to just return the original (unmerged)
string. What are the advantages of returning false instead of the original
string in the event of overlap?

 Returning false is useful tactic because it allows the user of the program to clearly know that something did not work with the patches they attempted to apply.
Also, the false that is returned in by the overlap? more clearly answers the question "do these two patches conflict" than the returning the original string
 
|#

(define patch1 (make-patch 158 (make-delete 4)))
(define patch2 (make-patch 158 (make-insert "It's totally")))
(define patch3 (make-patch 93 (make-delete 4)))
(define patch4 (make-patch 93 (make-insert "it is")))
(define patch5 (make-patch 89 (make-delete 4)))
(define patch6 (make-patch 79 (make-delete 8)))
(define patch7 (make-patch 79 (make-insert "golly")))
(define patch8 (make-patch 46 (make-delete 2)))
(define patch9 (make-patch 46 (make-insert "the")))
(define patch10 (make-patch 32 (make-insert "over there ")))
(define patch11 (make-patch 19 (make-delete 6)))
(define patch12 (make-patch 19(make-insert "the")))

(define original "Hamlet: Do you see yonder cloud that's almost in shape of a camel?Polonius: By the mass, and 'tis like a camel, indeed.[...]Hamlet: Or like a whale?Polonius: Very like a whale.")

(define alternative "Hamlet: Do you see the cloud over there that's almost the shape of a camel?Polonius: By golly, it is like a camel, indeed.[...]Hamlet: Or like a whale?Polonius: It's totally like a whale.")


;; modernize: string -> string
;; takes a string from hamlet and applies all the patches needed to modernize it
(check-expect (modernize original) alternative)
(define (modernize original)
 (apply-patch patch12 (apply-patch patch11 (apply-patch patch10 (apply-patch patch9 (apply-patch patch8 (apply-patch patch7 (apply-patch patch6 (apply-patch patch5 (apply-patch patch4 (apply-patch patch3 (apply-patch patch2 (apply-patch patch1 original)))))))))))))

                                       

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
 

~~~~~~~
8: (/ (- (* 9 3) (double 'a)) 2) where double is defined as (define (double n) (* n 2))
(/ (- (* 9 3) (double 'a)) 2)
      ^^^^^^^         
(/ (- 27 (double 'a)) 2)
          ^^^^^^^^^^
(/ (- 27 (* 'a 2)) 2)
         ^^^^^^^^
error: "expects a number as 1st argument, given 'a"
(or, in my own words: illegal argument given to the function *)


~~~~~~~
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
 
~~~~~~~ 
10: (and (+ 5 -1) false)
          ^^^^^^^
    (and 4 false)
    ^^^^^^^^^^^^^

error: "and: question result is not true or false: 4"
      (or, in my own words: "input type invadlid for function 'and'")

~~~~~~~
11: (apply-patch 'remove "this is a test string") [use your own apply-patch program from this assignment]

(apply-patch 'remove "this is a test string")
 ^^^^^^^^^^^
(apply-op (patch-operation 'remove) "this is a test string" (patch-position 'remove)))
           ^^^^^^^^^^^^^^^^^^^^^^^
Error: patch-operation: contract violation 
expected: patch
  given: 'remove


=====Debugging Racket Programs=====
For each of the following DrRacket error messages (from Beginner language level), describe what code that produces this error message would look like and provide a small illustrative example of code that would yield this error. Your description should not simply restate the error message!
 
~~~~~~~
12: cond: expected a clause with a question and answer, but found a clause with only one part
Code: (cond [(= 5 5)])
This error is caused by an incomplete cond expression, missing either a conditional function at the beginning or a clause which is evaluated after. If there are not two clauses in the square brackets: "(cond [])", that error will occur.

~~~~~~~
13: x: this variable is not defined
Code: (+ x 5)
This error message appears when x is used in a function but does not evaluate to a value. In this cas, it would be expected
that x would evaluate to an integer. But, it is not defined anywhere to be an integer. 

~~~~~~~
14: function call: expected a function after an open parenthesis, but found a number
Code: (+ (+ 1 2) (3))
This error message will appear when a number is wrapped around parenthesis. In the above example, "(3)" is causing the error.

|#

