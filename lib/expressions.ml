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
  | LetIn of string * expr * expr
  | Fun of string * expr
  | App of expr * expr
  | LetRec of string * expr * expr
  | Unit
  | Ref of expr 
  | Assign of expr * expr
  | Deref of expr
  | Raise of int
  | Try_with of expr*expr*string
  

(* Type pour les valeurs *)
type valeur = 
  | VI of int
  | VB of bool
  | VClosure of string * expr * environnement
  | VUnit
  | VAddr of int
  | VError of int

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

(* Fonction pour afficher une valeur *)
let affiche_valeur v = match v with 
  | VI k -> print_int k ; print_newline ()
  | VB b -> print_string (if b then "true" else "false") ; print_newline ()
  | VClosure _ -> print_string "<fun>" ; print_newline ()
  | VUnit -> print_string "()" ; print_newline () 
  | VAddr a -> print_string ("<ref:" ^ string_of_int a ^ ">") ; print_newline () 
  | VError s -> print_string ("Erreur : "); print_int s; print_newline()

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
  
  | LetIn(x, e1, e2) -> 
    let v1 = eval e1 env in
    let new_env = (x, v1) :: env in
    eval e2 new_env
  
  | Fun(x, e) ->
    VClosure(x, e, env)
  
  | App(e1, e2) ->
    let v_arg = eval e2 env in
    let v_fun = eval e1 env in
    (match v_fun with
    | VClosure(x, e, env_closure) ->
        let new_env = (x, v_arg) :: env_closure in
        eval e new_env
    | _ -> raise ApplicationNonFonction)
  
  | LetRec(f, e1, e2) ->
    (match e1 with
    | Fun(x, e) ->
        let rec new_env = (f, VClosure(x, e, new_env)) :: env in
        eval e2 new_env
    | _ -> raise (ErreurDeType "Let rec requiert une fonction"))

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
  | Raise s -> VError(s)
  |Try_with (e1, e2, k) -> let res = eval e1 env in begin match res with
    | VError(u) -> eval e2 ((k, VI(u))::env)
    | _ -> res
  end 

(* Version simplifiée de eval pour fouine.ml - sans environnement en paramètre *)
let eval e = 
  let env = [] in
  eval e env
