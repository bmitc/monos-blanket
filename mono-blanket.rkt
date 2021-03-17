#lang racket/gui

(require racket/runtime-path)
(require pict)

(define-runtime-path cloth-image "./mono_cloth.nto.png")

(define blanket-bitmap (read-bitmap cloth-image))

(define blanket-pict (bitmap blanket-bitmap))

(define SCALE 5)
(define WITH-GRID #f)
(define WITH-LABELS #f)
(define GRID-OFFSET (* 23 SCALE (/ 1 3.5)))
(define GRID-SIZE (* 35.7 SCALE (/ 1 3.5)))
(define row-labels #("A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L"))

(define scaled-blanket-pict (scale blanket-pict SCALE))

(define (draw canvas dc)
  (define width (pict-width scaled-blanket-pict))
  (define height (pict-height scaled-blanket-pict))
  (send dc set-smoothing 'smoothed)
  (draw-pict scaled-blanket-pict dc 0 0)
  (when WITH-GRID
    (send dc set-pen "Pale Green" 1 'solid)
    (for ([i (in-range 12)])
      (send dc draw-line
            GRID-OFFSET
            (+ (* i GRID-SIZE) GRID-OFFSET)
            width
            (+ (* i GRID-SIZE)GRID-OFFSET))
      (send dc draw-line
            (+ (* i GRID-SIZE) GRID-OFFSET)
            GRID-OFFSET
            (+ (* i GRID-SIZE) GRID-OFFSET)
            height)))
  (when WITH-LABELS
    (for ([i (in-range 12)])
      (for ([j (in-range 12)])
        (send dc draw-text
              (format "(~a,~a)" (vector-ref row-labels i) (+ j 1))
              (+ 5 (* j GRID-SIZE) GRID-OFFSET)
              (+ 5 (* i GRID-SIZE) GRID-OFFSET))))))

(define frame (new frame%
                   [label "Mono's Blanket"]
                   [stretchable-width #f]
                   [stretchable-height #f]))

(define main-panel (new horizontal-panel%
                        [parent frame]))

(define vertical-panel (new vertical-panel%
                            [parent main-panel]
                            [alignment (list 'left 'top)]))

(define canvas (new canvas%
                    [parent main-panel]
                    [min-width (exact-round (pict-width scaled-blanket-pict))]
                    [min-height (exact-round (pict-height scaled-blanket-pict))]
                    [paint-callback draw]))

(define show-grid (new check-box%
                       [parent vertical-panel]
                       [label "Show grid?"]
                       [value #f]
                       [callback
                        (lambda (check-box control-event)
                          (set! WITH-GRID (send check-box get-value))
                          (send canvas refresh-now))]))

(define show-labels (new check-box%
                         [parent vertical-panel]
                         [label "Show labels?"]
                         [value #f]
                         [callback
                          (lambda (check-box control-event)
                            (set! WITH-LABELS (send check-box get-value))
                            (send canvas refresh-now))]))

(send frame show #t)