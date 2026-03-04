let f x y = match x,y with
| true, true -> 50
| true, false -> 40
| false, _ -> 30 ;;
f false false  