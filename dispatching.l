# some dispatching

(de add-handler (Pred Fun)
   (push '*Handlers
      (cons Pred Fun)))


(de add-const-handler (X Fun)
   (add-handler (fcmd= X)
      Fun))

(de f= (@X)
   (fill '((x) (= @X x))))

(de fcmd= (@X)
   (fill '((X) (= @X (cadr (assoc 'cmd X))))))



(de handle (Msg)
   (mapcar (quote (x) (when ((car x) Msg)
                         ((cdr x) Msg) ) )
      *Handlers ) )    
                
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

