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
   (test '((action "sqrt") (args ("9")))
      (parse-action '((arg "!sqrt 9"))))
   (add-action "!sqrt" 'sqrt)
   (test '(("!sqrt" . sqrt)) *Actions))

(bye)


   