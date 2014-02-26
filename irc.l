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


(de ping? (Line)
   (= "PING" (car (words Line))))


(setq *IRC-Command-Handlers '())


(de irc-handler (Line)
   #(prinl "IRC-> " Line)
   (let (result
         (catch '("")
            (let (Msg (parse-ircmsg Line))
               (handle Msg)
               (handle-actions Msg)
               (logging-handler Line) )
            T ## we want to continue handling
            #Put first level handlers here  // not needed for bots
            ) )
      (unless (= T result)
         (error-handler result) ) )
   T)

(de error-handler (Err)
   (prinl "ERROR: " Err))

(de run-irc (Host Port Nick User Pass)
   (loop
      (telnet Host Port irc-handler (list (pack "PASS " Pass)
                                       (pack "NICK " Nick)
                                       (pack "USER " Nick " localhost.localdomain " User " :" Nick) ) ) ) )



(de parse-ircmsg (Msg)
   (let Words (words Msg)
      (if (= ":" (car (chop (car Words))))
         (list
            (list 'from (car Words))
            (list 'cmd (cadr Words))
            (list 'to (caddr Words))
            (list 'arg  (pack (cdr (chop (glue " " (cdddr Words)))))))
         (list
            (list 'cmd (car Words))
            (list 'msg (cadr Words))))))


(de logging-handler (Line)
   (prinl "Basic Logging Handler (redifine logging-handler to use own) :" Line))

#(trace 'handle)
#(trace 'privmsghandler)
#(trace 'handle-actions)            

   
