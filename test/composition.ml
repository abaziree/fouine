let compose = fun f g x -> f (g x) in
let add3 = fun x -> x + 3 in
let mult2 = fun x -> x * 2 in
let h = compose add3 mult2 in
prInt (h 7)
