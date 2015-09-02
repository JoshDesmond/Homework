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

;;TODOLIST:
;; Make sure variable names in functions are a-boa
;; INclude function: num -> string
;; Watch the indents


;;Insert is (make-insert String)
;; An operation that inserts a string at specific location
(define-struct insert (string))
(define INSERT-BLAH (make-insert "BLAH"))
;;template
;;*?? Do we need a template, it seems too sim

;; Delete is (make-delete number)
;; number of characters deleted at a point
;; ?? Do we need to specify negative numbers
(define-struct delete(number))
(define DELETE-5 (make-delete 5))
(define DELETE-0 (make-delete 0))


;; Operation is either insert or delete
#|
(define (operation-fun operation)
(cond [(insert? operation)... insert template here)
      [(delete? operation) ... delete template here)

|#

;; A patch is a (make-patch integer operation)
;; it takes a position to start, and operation done at this position 
(define-struct patch (position operation))
#|
(define (patch-fun patch)
  (patch-position patch)...
  (cond [(insert? (patch-operation operation))... )
        [(delete? (patch-operation operation)) ...)
|#
(define PATCH-EXAMPLE (make-patch 4 INSERT-BLAH))

;; Consumes an operation, a string, and a number
;; Produces the resulting string of applying the given operation
(define (apply-op operation string position)
  (cond [(insert? operation) (string-append (string-append (substring string 0 position)
                                                           (insert-string operation))
                                            (substring string position))]
        [(delete? operation)   (string-append (substring string 0 position) (substring string (+ position (delete-number operation))))]))
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


;;changes to overlap branch
;; Overlap?: patch patch -> boolean
;; consumes 2 patches and determines if they overlap
(check-expect (overlap? (make-patch 4 INSERT-BLAH)(make-patch 4 INSERT-BLAH)) true) 
(check-expect (overlap? (make-patch 4 DELETE3)(make-patch 4 DELETE3)) true) 
(check-expect (overlap? (make-patch 4 INSERT-BLAH)(make-patch 4 DELETE3)) true) 

(define (overlap? patchA patchB)
  (cond [(and (insert? (patch-operation patchA))
              (insert? (patch-operation patchB)))
         (insertion-overlap? patchA patchB)]
        [(and (delete? (patch-operation patchA))
              (delete? (patch-operation patchB)))
        (deletion-overlap? patchA patchB)]
         
          [else(mixed-overlap patchA patchB)]))




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

;;Deletion-overlap?: patch patch -> boolean
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
     
     #|  (check-expect (overlap? (make-patch INSERT-BLAH 4)
                        (make-patch INSERt-BlAH 4)) true)
(check-expect (overlap? (make-patch INSERT-BLAH 0)
                        (make-patch-BLAH 8)) false )
|#

;; put mixed overlap here!
(define (mixed-overlap patchA patchB)
  true)



     #|(check-expect (overlap? (make-patch INSERT-BLAH 0)
                        (make-patch INSERT-BLAH 8)))
(check-expect (overlap? (make-patch INSERT-BLAH 0)



(make-patch INSERT-BLAH 8)))
|#
     ;; Consumes two patches and a string
     ;; Produces a string of the result, or false if the patches
     ;;(define (merge string patch1 patch2)
     ;;)
     
     
     #| Question 6.)
In the previous question, we returned false in the event of an overlap. 
Another option might have been to just return the original (unmerged) 
string. What are the advantages of returning false instead of the original 
string in the event of overlap?


|#
     
     
     
     #|
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
     