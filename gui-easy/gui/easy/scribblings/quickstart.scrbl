#lang scribble/manual

@(require (for-label racket/base
                     racket/gui/easy
                     racket/gui/easy/operator))

@title{Quickstart}

@section{Hello, World!}

@racketblock[
  (window
   (text "Hello, World!"))
]

The code above describes a view hierarchy rooted in a window that
contains the text ``Hello, World!''.  By itself, it doesn't do much,
but you can take it and pass it to @racket[render] to convert it into
a native GUI:

@racketblock[
  (render
   (window
    (text "Hello, World!")))
]

@section{Counter}

State in @tt{gui-easy} is held by @tech{observables}.

@racketblock[
  (define |@count| (|@| 0))
  (render
   (window
    (hpanel
     (button "-" (λ () (|@count| . <~ . sub1)))
     (text (|@count| . ~> . number->string))
     (button "+" (λ () (|@count| . <~ . add1))))))
]

Here we define an observable called @racket[|@count|] that holds the
current value of a counter.  The two @racket[button]s change the value
of the counter when clicked and the @racket[text] view displays its
current string value via a derived observable.  The three widgets are
laid out horizontally by the @racket[hpanel].

@section{Counters}

Since views are at their core just descriptions of a GUI, it's easy to
abstract over them.

@racketblock[
  (define (counter |@count| action)
    (hpanel
     (button "-" (λ () (action sub1)))
     (text (|@count| . ~> . number->string))
     (button "+" (λ () (action add1)))))

  (define |@counter-1| (|@| 0))
  (define |@counter-2| (|@| 0))

  (render
   (window
    (vpanel
     (counter |@counter-1| (λ (proc) (|@counter-1| . <~ . proc)))
     (counter |@counter-2| (λ (proc) (|@counter-1| . <~ . proc))))))
]

Here we abstracted the counter from the previous example and made it
reusable.

@section{Dynamic Counters}

Taking the previous example even further, we can render a dynamic list
of counters.

@racketblock[
  (define (counter |@count| action)
    (hpanel
     (button "-" (λ () (action sub1)))
     (text (|@count| . ~> . number->string))
     (button "+" (λ () (action add1)))))

  (define |@counts| (|@| '((0 . 0))))

  (define (append-counter counts)
    (define next-id (add1 (apply max (map car counts))))
    (append counts `((,next-id . 0))))

  (define (update-count counts k proc)
    (for/list ([entry (in-list counts)])
      (if (eq? (car entry) k)
          (cons k (proc (cdr entry)))
          entry)))

  (render
   (window
    #:size '(#f 200)
    (vpanel
     (hpanel
      #:alignment '(center top)
      #:stretch '(#t #f)
      (button "Add counter" (λ ()
                              (|@counts| . <~ . append-counter))))
     (list-view
      |@counts|
      #:key car
      (λ (k |@entry|)
        (counter
         (|@entry| . ~> . cdr)
         (λ (proc)
           (|@counts| . <~ . (λ (counts)
                               (update-count counts k proc))))))))))
]

Here the @racket[|@counts|] observable holds a list of pairs where the
first element of a pair is the id of the counter and the second is its
count.  When the ``Add counter'' button is clicked, a new counter is
added to the set.  The @racket[list-view] renders each individual
counter by passing in a derived observable to its @racket[make-view]
argument.

@section{More}

@(define repo-link
  (link "https://github.com/Bogdanp/racket-gui-easy" "Git repository"))

For more examples, see the "examples" directory in the @|repo-link|.