open Expressions

(*Pour alléger l'affichage des opérations arithmétiques*)
let string_of_arop arop = match arop with 
  | Add -> "Add"
  | Mul -> "Mul"
  | Min -> "Min"
  | Div -> "Div"
  | Mod -> "Mod"

(* Pour alléger l'affichage des opéations booléennes binaires*)
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
  | MInt k -> print_int k
  | MBool b -> if b then print_string "true" else print_string "false"
  | MVar x -> print_string x
  | MWild -> print_string "_"
  | MUnit -> print_string "()"
  | MTuple ms -> print_string "(" ; List.iteri (fun i m -> affiche_motif m ; if i < List.length ms - 1 then print_string ", ") ms ; print_string ")"
  | MException m -> print_string "E " ; affiche_motif m 
  | MNil -> print_string "[]"
  | MCons(m1, m2) -> affiche_motif m1 ; print_string "::" ; affiche_motif m2
  | MList ms -> print_string "[" ; List.iteri (fun i m -> affiche_motif m ; if i < List.length ms - 1 then print_string ", ") ms ; print_string "]"
  | MConstructor(c, m_option) ->
    (match m_option with
    | None -> print_string c
    | Some m -> print_string c ; print_string " " ; affiche_motif m)

(* Fonction d'affichage des expressions*)
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
  | Function branches -> 
    print_string "Function(" ; print_string ", [" ;
    List.iteri (fun i (motifs, ei) -> List.iteri (fun j m -> affiche_motif m ; if j < List.length motifs - 1 then print_string " | ") motifs ; print_string " -> " ; affiche_expr ei ; if i < List.length branches - 1 then print_string " | ") branches ;
    print_string "])"
  | App(e1, e2) -> aff_aux "App(" [e1; e2]
  | LetRec(f, e1, e2) -> aff_aux ("LetRec(" ^ f ^ ", ") [e1; e2]
  | Unit -> print_string "()"
  | Ref e -> aff_aux "Ref(" [e]
  | Assign(e1, e2) -> aff_aux "Assign(" [e1; e2]
  | Deref e -> aff_aux "Deref(" [e]
  | Tuple es -> print_string "Tuple(" ; List.iteri (fun i e -> affiche_expr e ; if i < List.length es - 1 then print_string ", ") es ; print_string ")"
  | MatchWith(e, branches) -> 
    print_string "MatchWith(" ; affiche_expr e ; print_string ", [" ;
    List.iteri (fun i (motifs, ei) -> List.iteri (fun j m -> affiche_motif m ; if j < List.length motifs - 1 then print_string " | ") motifs ; print_string " -> " ; affiche_expr ei ; if i < List.length branches - 1 then print_string " | ") branches ;
    print_string "])"
  | Exception e -> print_string "Exception(" ; affiche_expr e ; print_string ")"
  | Raise e -> print_string "Raise(" ; affiche_expr e ; print_string ")"
  | TryWith (e, branches)-> 
    print_string "TryWith(" ; affiche_expr e ; print_string ", [" ;
    List.iteri (fun i (motifs, ei) -> List.iteri (fun j m -> affiche_motif m ; if j < List.length motifs - 1 then print_string " | ") motifs ; print_string "->" ; affiche_expr ei ; if i < List.length branches - 1 then print_string " | ") branches ;
    print_string "])"
  | Nil -> print_string "Nil"
  | Cons(a, l) -> aff_aux "Cons(" [a;l]
  | Type(t, branches, e) ->
    print_string ("Type(" ^ t ^ ", [") ;
    List.iteri (fun i (c, arite) -> print_string (c ^ " / ") ; print_int arite ; if i < List.length branches - 1 then print_string " | ") branches ;
    print_string "], " ; affiche_expr e ; print_string ")"
  | Constructor(c, e_option) ->
    (match e_option with
    | None -> print_string ("Constructor(" ^ c ^ ")")
    | Some e -> print_string ("Constructor(" ^ c ^ ", ") ; affiche_expr e ; print_string ")")


(* Fonction d'affichage des valeurs *) 
let rec affiche_val v =  match v with 
  | VI k -> print_int k
  | VB b -> print_string (if b then "true" else "false")
  | VClosure _ -> print_string "<fun>"
  | VFunctionClosure _ -> print_string "<fun>"
  | VUnit -> print_string "()"
  | VAddr a -> print_string ("<ref:" ^ string_of_int a ^ ">")
  | VTuple vs -> print_string "(" ; List.iteri (fun i v -> affiche_val v ; if i < List.length vs - 1 then print_string ", ") vs ; print_string ")"
  | VException k -> print_string "E " ; print_int k
  | VError k -> print_string "Exception: " ; print_int k
  | VList l -> print_string "[" ; List.iteri (fun i v -> affiche_val v ; if i < List.length l - 1 then print_string "; ") l ; print_string "]"
  | VConstructor(c, None) -> print_string c
  | VConstructor(c, Some v) ->
    print_string c ; print_string " " ;
    (match v with
    | VConstructor _ -> print_string "(" ; affiche_valeur v ; print_string ")"
    | _ -> affiche_valeur v)
