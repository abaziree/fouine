let fact_iter n =
  let result = ref 1 in
  let i = ref 1 in
  let rec loop () =
    if !i > n then ()
    else (
      result := !result * !i ;
      i := !i + 1 ;
      loop ()
    )
  in
  loop () ;
  !result
in
prInt (fact_iter 5)
