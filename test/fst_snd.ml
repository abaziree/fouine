let fst = fun (x, _) -> x in
let snd = fun (_, y) -> y in
let p = (10, 20) in
let _ = prInt (fst p) in
prInt (snd p)
