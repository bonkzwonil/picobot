#data im export

# Export all Logs and Words as plists



(mapcar getl
   (collect 'value '+Word))

(mapcar getl
   (collect 'raw '+Log))



(mapcar getl
   (collect 'nick '+Geek))

(mapcar getl
   (collect 'ts '+Bauch))

(mapcar getl
   (collect 'nsi '+Nsi))

