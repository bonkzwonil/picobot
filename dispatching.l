# some dispatching

(de add-handler (Pred Fun)
   (push '*Handlers
      (cons Pred Fun)))

(add-handler '((x) (= "quadrat" x))
             '((x) (* x x)) )

(de add-const-handler (X Fun)
   (add-handler (list '(y) (list '= X 'y))  ##how to do this nicer?
      Fun))

(de add-const-handler2 (X Fun)
   (bind (list (cons '@X X))
      (add-handler (fill '((x) (= @X x)))
         Fun ) ) )

(de add-const-handler3 (@X Fun)
   (add-handler (fill '((x) (= @X x)))
      Fun))



(add-const-handler3 "sqrt" 'sqrt) #easy as fuck




(de handle (msg arg)
   (mapcar (quote (x) (when ((car x) msg)
                         ((cdr x) arg)))
      *Handlers))
                
## Actions

#Oh glory Assoc Lists -- here we are again

(de add-action (Action Fun)
   (push '*Actions
      (cons Action Fun)))


(de handle-action (Action)
   ((cdr (assoc Action *Actions))))  # :)

      