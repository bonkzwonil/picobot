### Unit Tests

### Handlers

(use *Handlers
   (add-handler '((x) (= "length" x))
      '((x) (length x)) )
   (add-const-handler "sqrt" 'sqrt) #easy as fuck
   
   (test 2 (length *Handlers))
   (test '(NIL 6) (handle "length")))


## Actions
(use *Actions
   (test '((action "!sqrt") (args ("9")))
      (parse-action '((arg "!sqrt 9"))))
   (add-action "!sqrt" 'sqrt)
   (test '(("!sqrt" . sqrt)) *Actions))

(setq tstmsg ":irc.geekdav.com 376 picobot :End of MOTD command")
(setq tstmsg3 ":irc.geekdav.com PRIVMSG picobot :Hallo: blabla:::: ;)")
(setq tstmsg2 "PING :irc.geekdav.com") # Form2 ohne from: auch korrekt
(setq tstmsg4 ":bonk_FA!~bonk@sandkasten.mausland.de NICK :bonk_KAR")

(test 
   '((from ":irc.geekdav.com") (cmd "376") (to "picobot") (arg "End of MOTD command"))
   (parse-ircmsg tstmsg))


(test 
   '((cmd "PING") (msg ":irc.geekdav.com"))
   (parse-ircmsg tstmsg2))

(test
   T (ping? tstmsg2))

(parse-ircmsg tstmsg2)
(parse-ircmsg tstmsg3)



(bye)


   