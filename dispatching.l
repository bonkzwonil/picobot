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

(de parse-action (Msg)
   (let (Words (split (chop (cadr (assoc 'arg Msg))) " "))
      (list 
         (list 'action (pack (cdr (car Words))))
         (list 'args (mapcar 'pack (cdr Words))))))

(de handle-actions (Msg)
   (let (*Msg Msg  #Start a new Environment with some special Vars bound for reference
         *From (cadr (assoc 'from Msg))
         *Arg (cadr (assoc 'arg Msg))
         *Cmd (cadr (assoc 'cmd Msg))
         *To (cadr (assoc 'to Msg))
         ActionMsg (parse-action Msg)
         Action (cdr (assoc (cadr (assoc 'action ActionMsg)) *Actions)))
      (when Action
      
         (let Result (apply Action 
                        (cadr (assoc 'args ActionMsg)) )  # :)
            (when Result
               (telnet-send (pack "PRIVMSG " *To " " ":" Result) ) ) ) )))

      


(de privmsghandler (Msg)
   (let (Arg (cadr (assoc 'arg Msg)))
      (when (= "!" (car (chop Arg))) #Action?
         (handle-action Arg))))



### Actionfunctions

(de !help () "Hier kommt bald die Hilfe...")

(de !sqrt (X) (sqrt (format X)))

(de !env () (pack "Mein Momentanes dynamisches Environment: "
               " *From " *From
               " *Arg " *Arg
               " *Cmd " *Cmd
               " *To " *To))


####### WIRING

## Oder halt gleich in der struktur

#*Actions
(setq *Actions
   '(("!help" . !help)
     ("!eo" . (quote () (println "EEEEEEOOOOOO")))
     ("!sqrt" . !sqrt)
     ("!env" . !env)))

#*Handlers
(setq *Handlers
'((`(fcmd= "376") . (quote (msg)   ## END Of MOTD Hook (aka Successful Login)
                  (telnet-send "JOIN #juelich")))
  (`(fcmd= "PING") . (quote (Msg)
                     (telnet-send (pack "PONG " (cadr (assoc 'msg Msg) ) ))))
  
  (`(fcmd= "PRIVMSG") . privmsghandler) ) )    #geilo
