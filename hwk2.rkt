;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname hwk2) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
;; =====Homework Assigment 2=====
;; Josh Desmond & Saahil Claypool
;; ==============================
;; Assignment instructions:
;; http://web.cs.wpi.edu/~cs1102/a15/Assignments/Hwk2/index.html
;; Homework Guidelines:
;; http://web.cs.wpi.edu/~cs1102/a15/Assignments/grading-general.html


;;Delta: delta is (make-delta x y)
;; gives the x and y velocity of an object
(define-struct delta(x y))




;;plane: a plane is (make-plane image posn delta)
;; creates a plane with an image, position and velocity
(define-struct plane (image posn delta))

;; fire is a (make-fire int posn)
(define fire(make-fire intensity posn))
#|
(define (fire-fun a-fire)
     ( ... (fire-intensity a-fire)
           (fire-posn a-fire))


|#


;; list of fires (LoF) is either
;; (cons fire LoF)
;; or (cons empty)


;;world: 'holds' all the data / objects, one plane, list of fires


;; draw-world: world -> graphical scene
;;       (place-image (place-image empty)) --> put things on top of the same scene


;; update-world: world -> world
;; Takes in a world and produces a world after events that happen next happen

;;process-keys: world symbol -> world
;; makes changes to world depending on which keys are pressed







;; ############## Code to run world
;; (this takes in a world, each function takes that parameter
;(big-bang INITWORLD
;          (on-draw draw-world)
;          (on-tick update-world)
;          (on-key process-keys))