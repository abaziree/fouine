let f x y z = match x,y,z with
| 5,6,7 | 1,2,3 ->
    (match x with 
    | 1 -> 80
    | 2 -> 90
    | _ -> 100)
| _ -> 20
in
f 80 50 20