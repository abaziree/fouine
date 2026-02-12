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

(* Affichage d'un motif *)
let rec affiche_motif m = match m with
  | MCst k -> print_int k
  | MBool b -> if b then print_string "true" else print_string "false"
  | MVar x -> print_string x
  | MWild -> print_string "_"
  | MUnit -> print_string "()"
  | MTuple ms -> print_string "(" ; List.iteri (fun i m -> affiche_motif m ; if i < List.length ms - 1 then print_string ", ") ms ; print_string ")"

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
  | LetIn(m, e1, e2) -> print_string "LetIn(" ; affiche_motif m ; print_string ", " ; affiche_expr e1 ; print_string ", " ; affiche_expr e2 ; print_string ")"
  | Fun(m, e) -> print_string "Fun(" ; affiche_motif m ; print_string ", " ; affiche_expr e ; print_string ")"
  | App(e1, e2) -> aff_aux "App(" [e1; e2]
  | LetRec(f, e1, e2) -> aff_aux ("LetRec(" ^ f ^ ", ") [e1; e2]
  | Unit -> print_string "()"
  | Ref e -> aff_aux "Ref(" [e]
  | Assign(e1, e2) -> aff_aux "Assign(" [e1; e2]
  | Deref e -> aff_aux "Deref(" [e]
  | Tuple es -> print_string "(" ; List.iteri (fun i e -> affiche_expr e ; if i < List.length es - 1 then print_string ", ") es ; print_string ")"
  | MatchWith(e, branches) -> 
    print_string "MatchWith(" ; affiche_expr e ; print_string ", [" ;
    List.iteri (fun i (motifs, ei) -> List.iteri (fun j m -> affiche_motif m ; if j < List.length motifs - 1 then print_string " | ") motifs ; print_string "->" ; affiche_expr ei ; if i < List.length branches - 1 then print_string " | ") branches ;
    print_string "])"

let rec affiche_val v = match v with 
  | VI k -> print_int k
  | VB b -> if b then print_string "true" else print_string "false"
  | VClosure _ -> print_string "<fun>"
  | VUnit -> print_string "()"
  | VAddr a -> print_string ("<ref:" ^ string_of_int a ^ ">")
  | VTuple vs -> print_string "(" ; List.iteri (fun i v -> affiche_val v ; if i < List.length vs - 1 then print_string ", ") vs ; print_string ")"
