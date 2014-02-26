
## Logging objects
(class +Log +Entity)
(rel nick (+Idx +Need +String))
(rel nsi (+Ref +String))
(rel ts (+Need +Idx +String))
(rel cmd (+Need +Symbol +Ref))
(rel to (+Idx +String))
(rel arg (+Sn +Idx +String))
(rel raw (+String))



(class +Word +Entity)
(rel value (+Key +String +Need))
(rel log (+List +Ref +Link) NIL (+Log))

(de dblog (Line)
   (let Msg (parse-ircmsg Line)
      (let @Log 
         (new T '(+Log)
            'nick (nick (getA 'from Msg))
            'nsi (nsi (getA 'from Msg))
            'ts (stamp)
            'cmd (intern (getA 'cmd Msg))
            'to (getA 'to Msg)
            'arg (getA 'arg Msg)
            'raw Line )
         (mapcar (quote (@X)
                    (addword (wordify @X) @Log))
            (mapcar pack (split 
                            (chop (getA 'arg Msg))
                            " " ) ) ) ) ) )

(de wordify (Word Junklist)
   (let Junklist (or Junklist '(" " "," "." "!" ";"))
      (pack 
         (filter (quote (X)
                    (not (member X Junklist) ))
            (chop Word) ) ) ) )

(de addword (Word Log)
   (let (Obj (or 
                (db 'value '+Word Word)
                (new T '(+Word)
                   'value Word)))
      (put> Obj 'log Log)))  ###maybe getting too long? -- we will see

## Logging handler

(de logging-handler (Line)
   (out "+log.txt"
      (prinl (stamp) " " Line))
   (dblog Line) )

### Actionfunctions

(de !help () (pack "Actions: " (glue ", " (mapcar car *Actions))))

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



## Bauch
(de load-bauch-data (File)
   (in File 
         (read)))
      
      
(class +Geek +Entity)
(rel nick (+Key +Need +String))
(rel measures (+List +Joint) geek (+Bauch))

(class +Bauch +Entity)
(rel ts (+Need +String +Ref))
(rel cm (+Need +Number +Ref))
(rel geek (+Need +Joint) measures (+Geek)) 

(de bauch-add (Nick Cm Stamp)
   (new! '(+Bauch) 'ts (or Stamp (stamp)) 'cm Cm 'geek (db 'nick '+Geek Nick)))

(de bauch-convert (Lst)
   (let (Geek (car Lst))
      (new! '(+Geek) 'nick Geek)
      (mapcar (quote (X)
                 (bauch-add Geek (getf ':VALUE X) (getf ':DATE X)))
         (cadr Lst) ) ) )
   

(de nick (Nick)
   (lowc (pack (car (split (chop Nick) "_")))))
(de nsi (Nick)
   (pack (cadr (split (chop Nick) "_"))))


(de !bauch (Cmd)
   (bauch-add 
      (nick *From) Cmd))

(de !lastbauch (Nick)
   (let Bauch
      (last 
         (get (db 'nick '+Geek (nick Nick))
            'measures ) )
      (if Bauch
         (pack (nick Nick) " hatte am zuletzt " (get Bauch 'cm) " cm Bauch (" (get Bauch 'ts) ")" )
         "habe noch keine Bauchwerte von diesem Geek")))
      

# I like PLISTS
(de getf (X Place)
   (if Place
      (if (= X (car Place))
         (cadr Place)
         (getf X (cdr Place)))
      NIL))



#### NSI Database
(class +Nsi +Entity)
(rel nsi (+Need +Key +String))
(rel description (+Need +String))

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


(de nick-hook (Msg)
   (let Nsi (nsi (getA 'to Msg))
      (when (not (getnsi Nsi))
         (telnet-send 
            (pack "PRIVMSG #juelich :" (nick (getA 'to Msg))
               ": Was ist bitte '" Nsi "'? Bitte !regnsi. Dankesehr." ) ) ) ))
         

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
     ("!regnsi" . newnsi)
     ("!bauch" . !bauch) ))

#*Handlers
(setq *Handlers
'((`(fcmd= "376") . (quote (msg)   ## END Of MOTD Hook (aka Successful Login)
                  (telnet-send "JOIN #juelich")))
  (`(fcmd= "PING") . (quote (Msg)
                     (telnet-send (pack "PONG " (cadr (assoc 'msg Msg) ) ))))
  (`(fcmd= "NICK") . nick-hook)))
  
(de getConf (Sym)
   (getA Sym *BotConfig))

(dbs
   (1)
   (1 +Geek +Bauch +Nsi)
   (2 (+Geek measures) (+Bauch geek))
   (2 +Log)
   (3 (+Log nick nsi arg cmd ts))
   (2 (+Log raw))
   (1 +Word)
   (2 (+Word log)))
   

(pool "picobotdb/" *Dbs)   

(de traceall ()
   (trace 'logging-handler)                                
   (trace 'run-irc)                 
   (trace 'telnet-send)                           
   (trace 'intern)                        
   (trace 'new)                   
   (trace 'nick)                    
   (trace 'getA)                                                         
   (trace 'db))

(trace 'irc-handler)

(de error-handler (Err)
   (telnet-send (pack "PRIVMSG #juelich :" Err)))

(de main ()
   (run-irc 
      (getConf 'Host)
      (getConf 'Port)
      (getConf 'Nick)
      (getConf 'User)
      (getConf 'Pass)))
