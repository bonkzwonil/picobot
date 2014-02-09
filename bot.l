## Logging handler

(de logging-handler (Msg)
   (out "+log.txt"
      (prinl Msg)))

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


(de main ()
   (run-irc "localhost" 6667 "picobot" "PicoLisp" "d4nced4nce"))