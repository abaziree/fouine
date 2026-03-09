let test_exc n = 
  try 
    if n = 0 then raise (E 1)
    else if n < 0 then raise (E 2)
    else n
  with
    | E 1 -> 100
    | E 2 -> 200
in

prInt (test_exc 0) 