open Expressions

let string_of_arop arop = match arop with 
  | Add -> "Add"
  | Mul -> "Mul"
  | Min -> "Min"
  | Div -> "Div"
  | Mod -> "Mod"

let string_of_blop blop = match blop with 
  | Eq -> "Eq"
  | NEq -> "NEq"
  | LessEq -> "LessEq"
  | GreaterEq -> "GreaterEq"
  | Less -> "Less"
  | Greater -> "Greater"
  | And -> "And"
  | Or -> "Or"

(* Fonction d'affichage *)
let rec affiche_expr e =
  let aff_aux s l = 
    begin
      print_string s ;
      List.iteri (fun i e -> 
        affiche_expr e; 
        if i = (List.length l) - 1 then 
          print_string ")" 
        else 
          print_string ", "
      ) l ;
    end
  in
  match e with
  | Cst k -> print_int k
  | ArOp(arop, e1, e2) -> aff_aux ((string_of_arop arop) ^ "(") [e1; e2]
  | Bool b -> if b then print_string "true" else print_string "false"
  | IfThenElse(e1, e2, e3) -> aff_aux "IfThenElse(" [e1; e2; e3]
  | BlOp(blop, e1, e2) -> aff_aux ((string_of_blop blop) ^ "(") [e1; e2]
  | Not e -> aff_aux "Not(" [e]
  | PrInt e -> aff_aux "PrInt(" [e]
  | Ident x -> print_string ("Ident(" ^ x ^ ")")
  | LetIn(x, e1, e2) -> aff_aux ("LetIn(" ^ x ^ ", ") [e1; e2]
  | Fun(x, e) -> aff_aux ("Fun(" ^ x ^ ", ") [e]
  | App(e1, e2) -> aff_aux "App(" [e1; e2]
  | LetRec(f, e1, e2) -> aff_aux ("LetRec(" ^ f ^ ", ") [e1; e2]
  | Unit -> print_string "()"
  | Ref e -> aff_aux "Ref(" [e]
  | Assign(e1, e2) -> aff_aux "Assign(" [e1; e2]
  | Deref e -> aff_aux "Deref(" [e]
  | Raise s -> print_string("Raise("); print_int s; print_string (")")
  |Try_with (e1, e2, k)-> print_string "TryWith("; affiche_expr e1; print_string (", "^ k ^ ", ");  affiche_expr e2; print_string ")"

let affiche_val v = match v with 
  | VI k -> print_int k
  | VB b -> if b then print_string "true" else print_string "false"
  | VClosure _ -> print_string "<fun>"
  | VUnit -> print_string "()"
  | VAddr a -> print_string ("<ref:" ^ string_of_int a ^ ">");
  | VError s -> print_string ("Error "); print_int s 
