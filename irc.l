#### Matzes IRC

## Network Print with \r\n and flush
(de printn (txt)
    (when txt (prin txt))
    (wr 13)
    (wr 10)
    (flush))

(setq *TelnetSocket NIL)

(de telnet-send (Txt)
    (if (and Txt (lst? Txt)) # Not NIL
	(mapcar telnet-send Txt)
	(out *TelnetSocket (printn Txt))))


(de telnet (host port handler initlines)  ##maybe better multithread?
   (let (s (connect host port))
      (setq *TelnetSocket s)
      (telnet-send initlines)
      (in s
	  (loop
	     (NIL (handler (line T)) (close s))))))


# (telnetsession "www.google.de" 80 handler '("GET / HTTP/1.1" "Connection: close" ""))    

(setq +IRC-ENDOFNAMES 366)



(de words (txt)
   (mapcar pack (split (chop txt) " ")))


(setq *IRC-Command-Handlers '())


(de irc-handler (Line)
   #(prinl "IRC-> " Line)
   (handle (parse-ircmsg Line))
   (handle-actions (parse-ircmsg Line))
   (logging-handler Line)
   #Put handler here
 )   

o(de run-irc (Host Port Nick User Pass)
	(loop
   (telnet Host Port irc-handler (list (pack "PASS " Pass)
                                       (pack "NICK " Nick)
                                       (pack "USER " Nick " localhost.localdomain " User " :" Nick)))))


(setq tstmsg ":irc.geekdav.com 376 picobot :End of MOTD command")
(setq tstmsg3 ":irc.geekdav.com PRIVMSG picobot :Hallo: blabla:::: ;)")
(setq tstmsg2 "PING :irc.geekdav.com") # Form2 ohne from: auch korrekt
(setq tstmsg4 ":bonk_FA!~bonk@sandkasten.mausland.de NICK :bonk_KAR")

(de parse-ircmsg (Msg)
   (let Words (mapcar pack (split (chop Msg) " "))
      (if (= ":" (car (chop Msg)))
         (list
            (list 'from (car Words))
            (list 'cmd (cadr Words))
            (list 'to (caddr Words))
            (list 'arg  (pack (tail (* -1 (index ":" (cdr (chop Msg)))) (chop Msg))))) ##bad
         (list
            (list 'cmd (car Words))
            (list 'msg (cadr Words))))))

(parse-ircmsg tstmsg)
(parse-ircmsg tstmsg2)
(parse-ircmsg tstmsg3)


#(trace 'handle)
#(trace 'privmsghandler)
#(trace 'handle-actions)            

   
