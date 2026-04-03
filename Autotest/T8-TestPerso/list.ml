type test = S of int ;;
let x = 1 :: 2 :: [] in 
let y = 1+2::[3] in
match x, y with
| x1::l1, x2::l2 -> prInt x1
| _ -> prInt 7