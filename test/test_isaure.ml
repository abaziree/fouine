type test = T of bool | I of int ;;
let f x = T x in
match f false with
| T true -> [8]
| T false -> let x = ref 3 in !x::[(x := 42 ; !x)]
| _ -> [9]