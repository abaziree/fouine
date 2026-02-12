(* Types pour les opérateurs arithmétiques et booléens binaires *)
type arop =
  | Add
  | Mul 
  | Min
  | Div 
  | Mod

type blop =
  | Eq
  | NEq
  | LessEq 
  | GreaterEq 
  | Less 
  | Greater
  | And 
  | Or

(* Type pour les motifs *)
type motif =
  | MVar of string          
  | MWild                  
  | MUnit                
  | MTuple of motif list 

(* Type pour les expressions *)
type expr =
  | Cst of int
  | ArOp of arop * expr * expr
  | Bool of bool
  | IfThenElse of expr * expr * expr
  | BlOp of blop * expr * expr
  | Not of expr
  | PrInt of expr
  | Ident of string
  | LetIn of motif * expr * expr
  | Fun of motif * expr
  | App of expr * expr
  | LetRec of string * expr * expr
  | Unit
  | Ref of expr 
  | Assign of expr * expr
  | Deref of expr
  | Tuple of expr list
  | MatchWith of expr * (motif * expr) list
  

(* Type pour les valeurs *)
type valeur = 
  | VI of int
  | VB of bool
  | VClosure of motif * expr * environnement
  | VUnit
  | VAddr of int
  | VTuple of valeur list

(* Type pour l'environnement (association variable -> valeur) *)
and environnement = (string * valeur) list

(* Tas pour représenter la mémoire *)

let tas_size = 1234
let tas = Array.make tas_size VUnit
let next_addr = ref 0

(* Exceptions pour la gestion des erreurs *)
exception DivisionParZero
exception VariableNonDefinie of string
exception ErreurDeType of string
exception ConditionNonBooleenne
exception ApplicationNonFonction
exception TasPlein 
exception AdresseInvalide of int
exception FiltrageSansCorrespondance

(* Fonction pour afficher une valeur *)
let rec affiche_valeur v = match v with 
  | VI k -> print_int k ; print_newline ()
  | VB b -> print_string (if b then "true" else "false") ; print_newline ()
  | VClosure _ -> print_string "<fun>" ; print_newline ()
  | VUnit -> print_string "()" ; print_newline () 
  | VAddr a -> print_string ("<ref:" ^ string_of_int a ^ ">") ; print_newline () 
  | VTuple vs -> print_string "(" ; List.iteri (fun i v -> affiche_valeur v ; if i < List.length vs - 1 then print_string ", ") vs ; print_string ")" ; print_newline ()

(* Recherche d'une variable dans l'environnement *)
let rec cherche_var x env = match env with
  | [] -> raise (VariableNonDefinie x)
  | (y, v) :: rest -> if x = y then v else cherche_var x rest

(* Allouer une nouvelle adresse dans le tas *)
let allouer valeur =
  if !next_addr >= tas_size then
    raise TasPlein
  else
    let addr = !next_addr in
    tas.(addr) <- valeur ;
    incr next_addr ;
    addr
  
(* Lire une valeur dans le tas *)
let lire_tas addr =
  if addr < 0 || addr >= !next_addr then
    raise (AdresseInvalide addr)
  else
    tas.(addr)

(* Écrire une valeur dans le tas *)
let ecrire_tas addr valeur =
  if addr < 0 || addr >= !next_addr then
    raise (AdresseInvalide addr)
  else
    tas.(addr) <- valeur

(* Tente de faire correspondre un motif à une valeur *)
let rec filtre motif valeur = match motif, valeur with
  | MWild, _ -> Some []
  | MUnit, VUnit -> Some []
  | MVar x, v -> Some [(x, v)]
  | MTuple ms, VTuple vs when List.length ms = List.length vs ->
    List.fold_left2 (fun acc m v -> 
      match acc with
      | None -> None
      | Some bindings ->
        (match filtre m v with
        | None -> None
        | Some new_bindings -> Some (bindings @ new_bindings)))
      (Some []) ms vs
  | _ -> None

(* Évaluation d'une expression dans un environnement *)
let rec eval expr env = match expr with 
  | Cst k -> VI k
  
  | ArOp(arop, e1, e2) ->
    let v1 = eval e1 env in
    let v2 = eval e2 env in
    (match (arop, v1, v2) with
    | (Add, VI k1, VI k2) -> VI (k1 + k2)
    | (Mul, VI k1, VI k2) -> VI (k1 * k2)
    | (Min, VI k1, VI k2) -> VI (k1 - k2)
    | (Div, VI k1, VI k2) -> 
        if k2 = 0 then raise DivisionParZero
        else VI (k1 / k2)
    | (Mod, VI k1, VI k2) -> 
        if k2 = 0 then raise DivisionParZero
        else VI (k1 mod k2)
    | _ -> raise (ErreurDeType "Les opérations arithmétiques requièrent des entiers"))
  
  | Bool b -> VB b
  
  | IfThenElse(e1, e2, e3) -> 
    let v1 = eval e1 env in
    (match v1 with
    | VB true -> eval e2 env
    | VB false -> eval e3 env
    | _ -> raise ConditionNonBooleenne)
  
  | BlOp(Or, e1, e2) ->
    let v1 = eval e1 env in 
    (match v1 with
    | VB true -> VB true          (* || feignant *)
    | VB false -> 
        let v2 = eval e2 env in 
        (match v2 with 
        | VB b -> VB b
        | _ -> raise (ErreurDeType "L'opérateur || requiert des booléens"))
    | _ -> raise (ErreurDeType "L'opérateur || requiert des booléens"))
  
  | BlOp(And, e1, e2) ->
    let v1 = eval e1 env in 
    (match v1 with
    | VB false -> VB false        (* && feignant *)
    | VB true -> 
        let v2 = eval e2 env in 
        (match v2 with 
        | VB b -> VB b
        | _ -> raise (ErreurDeType "L'opérateur && requiert des booléens"))
    | _ -> raise (ErreurDeType "L'opérateur && requiert des booléens"))
  
  | BlOp(blop, e1, e2) ->
    let v1 = eval e1 env in 
    let v2 = eval e2 env in 
    (match (blop, v1, v2) with
    | (Eq, VI k1, VI k2) -> VB (k1 = k2)
    | (Eq, VB b1, VB b2) -> VB (b1 = b2)
    | (NEq, VI k1, VI k2) -> VB (k1 <> k2)
    | (NEq, VB b1, VB b2) -> VB (b1 <> b2)
    | (LessEq, VI k1, VI k2) -> VB (k1 <= k2)
    | (LessEq, VB b1, VB b2) -> VB (b1 <= b2)
    | (GreaterEq, VI k1, VI k2) -> VB (k1 >= k2)
    | (GreaterEq, VB b1, VB b2) -> VB (b1 >= b2)
    | (Less, VI k1, VI k2) -> VB (k1 < k2)
    | (Less, VB b1, VB b2) -> VB (b1 < b2)
    | (Greater, VI k1, VI k2) -> VB (k1 > k2)
    | (Greater, VB b1, VB b2) -> VB (b1 > b2)
    | _ -> raise (ErreurDeType "Comparaison entre types incompatibles"))
  
  | Not e ->
    let v = eval e env in
    (match v with
    | VB b -> VB (not b)
    | _ -> raise (ErreurDeType "L'opérateur not requiert un booléen"))
  
  | PrInt e ->
    let v = eval e env in 
    (match v with
    | VI k -> print_int k ; print_newline () ; VI k
    | _ -> raise (ErreurDeType "prInt requiert un entier"))
  
  | Ident x -> cherche_var x env
  
  | LetIn(m, e1, e2) -> 
    let v1 = eval e1 env in
    (match filtre m v1 with
    | Some bindings -> eval e2 (bindings @ env)
    | None -> raise FiltrageSansCorrespondance)
  
  | Fun(m, e) ->
    VClosure(m, e, env)
  
  | App(e1, e2) ->
    let v_arg = eval e2 env in
    let v_fun = eval e1 env in
    (match v_fun with
    | VClosure(m, e, env_closure) ->
      (match filtre m v_arg with
      | Some bindings -> eval e (bindings @ env_closure)
      | None -> raise FiltrageSansCorrespondance)
    | _ -> raise ApplicationNonFonction)
  
  | LetRec(f, e1, e2) ->
    (match e1 with
    | Fun(m, e) ->
        let rec new_env = (f, VClosure(m, e, new_env)) :: env in
        eval e2 new_env
    | _ -> eval (LetIn(MVar f, e1, e2)) env)

  | Unit -> VUnit

  | Ref e ->
    let v = eval e env in
    let addr = allouer v in
    VAddr addr

  | Assign(e1, e2) ->
    let v1, v2 = eval e1 env, eval e2 env in
    (match v1 with 
    | VAddr addr -> ecrire_tas addr v2 ; VUnit
    | _ -> raise (ErreurDeType "L'affectation requiert une référence"))

  | Deref e ->
    let v = eval e env in
    (match v with
    | VAddr addr -> lire_tas addr
    | _ -> raise (ErreurDeType "Le déréférencement requiert une référence"))

  | Tuple es ->
    let vs = List.map (fun e -> eval e env) es in
    VTuple vs

  | MatchWith(e, branches) ->
    let v = eval e env in
    let rec essaie_branches brch = match brch with
    | [] -> raise FiltrageSansCorrespondance
    | (m, e)::reste ->
      (match filtre m v with
      | Some bindings -> eval e (bindings @ env)
      | None -> essaie_branches reste)
    in 
    essaie_branches branches

(* Version simplifiée de eval pour fouine.ml - sans environnement en paramètre *)
let eval e = 
  let env = [] in
  eval e env
