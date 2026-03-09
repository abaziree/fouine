let compteur = ref 0 in
let incr = fun () ->
  compteur := !compteur + 1 ;
  !compteur
in
let _ = prInt (incr ()) in
let _ = prInt (incr ()) in
prInt (incr ())
