type test = T of bool | I of int ;;
let f x = T x in
let rec print_l l = match l with
| [] -> ()
| h::t -> prInt h ; print_l t
in
match f false with
| T true -> print_l [8;9;4]
| T false -> print_l [4]
| _ -> print_l [7;999;584;1]