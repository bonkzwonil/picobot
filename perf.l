# performance test

(class +Test +Entity)
(rel aid (+Key +Need +Number))
(rel key (+Ref +String))
(rel payload (+String))

(dbs (1)
   (1 +Test)
   (1 (+Test aid))
   (2 (+Test key)))

(pool "test.data" *Dbs)


(for N 10
   (bench (for I 100000
             (new (db: +Test) '(+Test)
                'aid (+ (* 100000 N) I)
                'key (pack "KEY: " (+ (* 10000 N) I))
                'payload (pack "Hallo " N " und " I) ) )
      (commit)
      (prune) 
 )
   (prinl N))

(0)