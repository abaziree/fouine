let test = fun p ->
  match p with
  | (0, _) -> 0
  | (1, y) -> 10 + y
  | (x, y) -> x * y
in
let _ = prInt (test (0, 5)) in
let _ = prInt (test (1, 3)) in
prInt (test (4, 5))
