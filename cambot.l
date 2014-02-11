(de logging-handler Line (println Line))
#*Handlers
(setq *Handlers
'((`(fcmd= "376") . (quote (msg)   ## END Of MOTD Hook (aka Successful Login)
                  (telnet-send "JOIN #juelich")))
  (`(fcmd= "332") . (quote (msg) (telnet-send "PRIVMSG #juelich :Obacht! Es wurde gerade eine Bewegung in der BKW aufgezeichnet, fyi!")
  				(bye)))))                

(de getA (Sym ALst)
   (cadr (assoc Sym ALst)))

(de getConf (Sym)
   (getA Sym *BotConfig))

(de main ()
   (run-irc 
      (getConf 'Host)
      (getConf 'Port)
      (getConf 'Nick)
      (getConf 'User)
      (getConf 'Pass)))