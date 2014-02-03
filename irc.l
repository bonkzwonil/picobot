; Matzes IRC

(de printn (txt)
    (prin txt)
    (wr 13)
    (wr 10)
    (flush))

(printn "Hallo Welt")



(de test (url)
    (let (s (connect url 80))
      (out s 
	   (printn "GET / HTTP/1.0")
	   (printn "Host: www.google.de")
	   (printn "Connection: close")
	   (printn)	
	   (flush))
      (in s
	  (loop
	     (println "loop")
	     (NIL (println (line t)) (close s))))))
    
