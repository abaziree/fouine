let _ = prInt (if true || (1/0 = 0) then 1 else 0) in
let _ = prInt (if false && (1/0 = 0) then 1 else 0) in
prInt (if true || false then 1 else 0)
