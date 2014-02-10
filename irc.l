#### Matzes IRC

## Network Print with \r\n and flush
(de printn (txt)
    (prin txt)
    (wr 13)
    (wr 10)
    (flush))

(setq *TelnetSocket NIL)

(de telnet-send (Line)
   (out *TelnetSocket
      (printn Line)))

(de telnet (host port handler initlines)  ##maybe better multithread?
   (let (s (connect host port))
      (setq *TelnetSocket s)
      (out s
         (mapcar printn initlines))
      (in s
         (use Line 
            (loop 
               (NIL (setq Line (line)) (close s))
               (handler Line) ) ) ) ))

(de irc-handler (Line)
   #(prinl "IRC-> " Line)
   (handle (parse-ircmsg Line))
   (handle-actions (parse-ircmsg Line))
   (logging-handler Line)
   #Put handler here
 )   

(de run-irc (Host Port Nick User Pass)
	(loop
   (telnet Host Port irc-handler (list (pack "PASS " Pass)
                                       (pack "NICK " Nick)
                                       (pack "USER " Nick " localhost.localdomain " User " :" Nick)))))


(setq tstmsg ":irc.geekdav.com 376 picobot :End of MOTD command")
(setq tstmsg3 ":irc.geekdav.com PRIVMSG picobot :Hallo: blabla:::: ;)")
(setq tstmsg2 "PING :irc.geekdav.com") # Form2 ohne from: auch korrekt


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
(trace 'telnet-send)
(trace 'privmsghandler)
(trace 'handle-actions)            

   
   