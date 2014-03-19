# add an index to theWordIdx
(setq *Class '+WordLog)

(rel aid (+Key +Number))
(dbs+ 15 (0 (+WordLog aid)))

(de addIdx ()
   (let N 0
      (for (Obj (seq (db: +WordLog)) Obj (seq Obj))
         (when (isa '+WordLog Obj)
            (put> Obj 'aid (inc 'N))
            (at (0 . 10000) (commit))))
      N ) )

(de addLastLogs ()
   (let (Q (init (tree 'aid '+WordLog) T))
      (while (step Q)
         (let X @
            (let Word (get X 'word)
               (unless (get Word 'lastLog)
                  (put> Word 'lastLog (get X 'log))
                  (at (0 . 10000) (prinl "commit") (prinl (count (tree 'lastLog '+Word))) (commit) (prune) (gc 0)) ) ) ))))