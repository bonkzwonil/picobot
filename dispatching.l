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

(de f= (@X)
   (fill '((x) (= @X x))))

(de fcmd= (@X)
   (fill '((X) (= @X (cadr (assoc 'cmd X))))))


(add-const-handler3 "sqrt" 'sqrt) #easy as fuck




(de handle (Msg)
   (mapcar (quote (x) (when ((car x) Msg)
                         (prinl "Matching Handler!")
                         ((cdr x) Msg) ) )
      *Handlers))
                
## Actions

#Oh glory Assoc Lists -- here we are again

(de add-action (Action Fun)
   (push '*Actions
      (cons Action Fun)))


(de handle-action (Action)
   ((cdr (assoc Action *Actions))))  # :)

## Oder halt gleich in der struktur

#*Actions
(setq *Actions
   '(("!help" . (quote () "Hilfe"))
     ("!eo" . (quote () (println "EEEEEEOOOOOO"))) ))

#*Handlers
(setq *Handlers
'((`(fcmd= "376") . (quote (msg)
                  (telnet-send "JOIN #juelich")))
  (`(fcmd= "PING") . (quote (msg)
                     (telnet-send (pack "PONG " (cadr (assoc 'msg) ) ))))
  
  (`(fcmd= "kramso") . chop) ))    #geilo
      