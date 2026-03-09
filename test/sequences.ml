let x = ref 0 in
let _ = x := 1 ; prInt (!x) in
let _ = x := 2 ; prInt (!x) in
let _ = x := 3 ; prInt (!x) in
x := !x * 2 ;
prInt (!x)
