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

(de !bkw () (let (Info 
                  (info "/export/storage/motiondetected")
                  File
                  (pack (car (reverse (split (chop (in "/export/storage/motiondetected" (line T))) "/")))))

	(pack "Die letzte Bewegung in der BKW war: "
		(stamp (cadr Info) (+ 3600 (cddr Info))) 
                " https://geekdav.com/BKW/" File)))
		 

(setq *M4Z-NotAllowed '( "www" "bonk" "router" "ns" "mx" "mail" ))
(de ip? (Ip)
   (let Tst (mapcar num?
               (mapcar format
                  (mapcar pack (split (chop Ip) ".")) ) )
      (and (= 4 (size Tst))
         (not (member NIL Tst)))))

(de !m4z (Host Ip)
   (if (member (lowc Host) *M4Z-NotAllowed)
      "Ne, der host is nich erlaubt bzw schon weg..."
      (if (not (ip? Ip))
         "Komische Ip..."
         (call 'updatens Host Ip)
         (pack "Updated " Host " to " Ip) ) ) )



#### NSI Database
(class +Nsi +Entity)
(rel nsi (+Need +Key +String))
(rel description (+Need +String))

(pool "nsi.db")   

(de addnsi (Line)
   (let (Nsi (car (words Line))
         Descr (pack (trim (chop (pack (mapcar '((X) (pack X " ")) (cdr (words Line))))))))
      (println Nsi Descr)
      (new! '(+Nsi)
         'nsi Nsi
         'description Descr)))

(de newnsi @  # Nsi Sentence
	(if (getnsi (next))
	"gibts schon"
	(prog
      (new! '(+Nsi)
         'nsi (arg)
         'description (glue " " (rest)))
         (commit))))
#      (put *DB Nsi Descr) ) )

   
(de getnsi (Nsi)
    (get (db 'nsi '+Nsi Nsi) 'description))



(de readnsis (File)
   (in File
      (loop
         (NIL (line T)  'done)
         (addnsi @))))
         

####### WIRING



## Oder halt gleich in der struktur

#*Actions
(setq *Actions
   '(("!help" . !help)
     ("!eo" . (quote () (println "EEEEEEOOOOOO")))
     ("!sqrt" . !sqrt)
     ("!env" . !env)
     ("!m4z" . !m4z)
     ("!bkw" . !bkw)
     ("!whatis" . getnsi) 
     ("!regnsi" . newnsi) ) )

#*Handlers
(setq *Handlers
'((`(fcmd= "376") . (quote (msg)   ## END Of MOTD Hook (aka Successful Login)
                  (telnet-send "JOIN #juelich")))
  (`(fcmd= "PING") . (quote (Msg)
                     (telnet-send (pack "PONG " (cadr (assoc 'msg Msg) ) ))))
  
  (`(fcmd= "PRIVMSG") . privmsghandler) ) )    #geilo

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