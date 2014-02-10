## Matzes IRC

# Telnet helper
(de printn (txt)
    (when txt (prin txt))
    (wr 13)
    (wr 10)
    (flush))

(de sendtelnet (txt)
    (if (and txt (lst? txt)) # Not NIL
	(mapcar sendtelnet txt)
	(out *TelnetSocket (printn txt))))


(de telnetsession (host port linehandler initlines)
    (let (socket (connect host port))
      (setq *TelnetSocket socket)
      (sendtelnet initlines)
      (in socket
	  (loop
	     (NIL (linehandler (line T)) (close socket))))
      socket))

(de handler (line)
    (println line))
	     
#(trace 'prin)
#(trace 'printn)
(trace 'sendtelnet)
(trace 'handler)
(trace 'connect)

# (telnetsession "www.google.de" 80 handler '("GET / HTTP/1.1" "Connection: close" ""))    

(setq +IRC-ENDOFNAMES 366)

(de words (txt)
   (mapcar pack (split (chop txt) " ")))

# IRC STuff
(de irc-command (msg)
   (cadr (words msg)))
(de irc-target (msg)
   (caddr (words msg)))

##FIXME: BAAAAD
(de irc-arg (msg)
   (pack (cdr
      (split 
         (chop (glue " " (cdr (words msg))))
         ":" ))))
(de irc-source (msg)
   (car (words msg)))

# Bot Stuff


(de irc-connect (nick user handler)
   (telnetsession "localhost" 6667 handler (list
                                              "PASS d4nced4nce"
                                              (pack "NICK " nick)
                                              (pack "USER " nick " localhost.localdomain " user " :" nick)
                                              "JOIN #juelich" )))


(setq *IRC-Command-Handlers '())

(de irc-handler (msg)
   (mapcar '((x) (x msg)) *IRC-Command-Handlers))

(trace 'irc-handler)
(debug 'irc-handler)


(de irc-add-command-handler (command fun)
   (push 'IRC-Command-Handlers (list '(msg)
                                  (list 'when (list '= '(irc-command msg)
						    command )
					(list fun '(msg))))))

# HOW TO DO DA FUCK?!                                    
   

## the bot


(irc-add-command-handler "366" (quote (x) (sendtelnet "JOIN #juelich")))

(irc-add-command-handler "PING" (quote (x) (sendtelnet (pack "PONG :" (irc-arg x)))))


(irc-add-command-handler "PRIVMSG" (quote (x) (when (= "eo" (irc-arg x)) 
                                                 (sendtelnet "eo!"))))




## fire it up
(de main ()
   (irc-connect "picobot" "picolisp" irc-handler))
   

(set 'tstmsg ":BotZwoNil!~BotZwoNil@sandkasten.mausland.de PRIVMSG #juelich :hahahah diese 90jährige basiccodering")
#":bonk_AT!~bonk@sandkasten.mausland.de PRIVMSG #juelich :inkl basic telnet und irc logon"
