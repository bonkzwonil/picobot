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

(de getA (Sym ALst)
   (cadr (assoc Sym ALst)))


(de add-action (Action Fun)
   (push '*Actions
      (cons Action Fun)))

(de action? (Msg)
	(= "!" (car (chop (getA 'arg Msg)))))

(de parse-action (Msg)
   (if (action? Msg)
      (let (Words (words (getA 'arg Msg)))
         (list 
            (list 'action (car Words))
            (list 'args (mapcar 'pack (cdr Words)))))
      NIL))


(setq *MinActionIntvl 1) # 1sec
(setq *LastActionTime 0)


(de minTimePassed? ()
   (> (- (time) *LastActionTime)
      *MinActionIntvl))

(de ircsend (Line)
   (telnet-send 
      (pack (head 500 (chop Line)))))

(de handle-actions (Msg)
 (when (action? Msg)
   (if (minTimePassed?)
      (let (*Msg Msg  #Start a new Environment with some special Vars bound for reference
            *From (getA 'from Msg)
            *Arg (getA 'arg Msg)
            *Cmd (getA 'cmd Msg)
            *To (getA 'to Msg)
            ActionMsg (parse-action Msg)
            Action (cdr (assoc (cadr (assoc 'action ActionMsg)) *Actions)) )
         (setq *LastActionTime (time))
         (when Action
      
            (let Result (apply Action 
                           (getA 'args ActionMsg))   # :)
               (when Result
                  (ircsend (pack "PRIVMSG " (if (= (getConf 'Nick) *To) *From *To) " :" Result)) ) ) ) )
      #else
      (println "Action is calling too fast... Ignore this one: " Msg) ) ) )


      


