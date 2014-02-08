; Matzes IRC

;;Network Print with \r\n and flush
(de printn (txt)
    (prin txt)
    (wr 13)
    (wr 10)
    (flush))

(setq *IrcSocket NIL)

(de telnet-send (Line)
   (out *IrcSocket
      (printn Line)))

(de telnet (host port handler initlines)  ##maybe better multithread?
   (let (s (connect host port))
      (setq *IrcSocket s)
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
   #(handle-action 
   #Put handler here
 )   

(de run-irc (Host Port Nick User Pass)
   (telnet Host Port irc-handler (list (pack "PASS " Pass)
                                       (pack "NICK " Nick)
                                       (pack "USER " Nick " localhost.localdomain " User " :" Nick))))


(setq tstmsg ":irc.geekdav.com 376 picobot :End of MOTD command")
(setq tstmsg2 "PING :irc.geekdav.com") # auch korrekt


(de parse-ircmsg (Msg)
   (let Words (mapcar pack (split (chop Msg) " "))
      (if (= ":" (car (chop Msg)))
         (list
            (list 'from (car Words))
            (list 'cmd (cadr Words))
            (list 'to (caddr Words))
            (list 'arg (caddr (mapcar pack (split (chop Msg) ":")))))
         (list
            (list 'cmd (car Words))
            (list 'msg (cadr Words))))))


(trace 'handle)
(trace 'telnet-send)
(trace 'privmsghandler)
(trace 'handle-action)            

   
   