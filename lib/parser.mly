%{
(* --- Préambule : code OCaml --- *)
open Expressions
%}

/* PARTIE 2 : Liste des lexèmes */
%token PLUS TIMES MINUS DIVIDE MODULO
%token LPAREN RPAREN
%token EOF
%token <int> INT
%token IF THEN ELSE
%token EQ NEQ LESS GREATER LESS_EQ GREATER_EQ
%token AND OR NOT
%token <bool> BOOL
%token BEGIN END
%token PRINT
%token <string> IDENT
%token LET REC IN
%token SEMISEMI
%token UNDERSCORE
%token FUN FUNCTION ARROW
%token REF ASSIGN DEREF
%token SEMI
%token COMMA 
%token MATCH WITH PIPE
%token RAISE 
%token EXCEPTION
%token TRY
%token NIL CONS LCROCHET RCROCHET
%token TYPE OF
%token <string> CONSTRUCTOR


/* Token de priorités */
%token PRIO_PIPE
%token PRIO_TUPLE
%token PRIO_NO_TUPLE_EXPR_OP

/* PARTIE 3 : Associativités et priorités */
%nonassoc IN PRIO_PIPE
%right PIPE
%nonassoc PRIO_TUPLE
%right ARROW
%right CONS
%right SEMI RCROCHET
%nonassoc ASSIGN
%left CONSTRUCTOR
%left OR
%left AND
%nonassoc NOT
%left EQ NEQ LESS GREATER LESS_EQ GREATER_EQ
%left PLUS MINUS
%nonassoc PRIO_NO_TUPLE_EXPR_OP
%left TIMES DIVIDE MODULO
%nonassoc INT BOOL IDENT NIL DEREF BEGIN LPAREN LCROCHET 
%nonassoc UNDERSCORE EXCEPTION

/* PARTIE 4 : Point d'entrée */
%start main
%type <Expressions.expr> main

/* PARTIE 5 : Grammaire */
%%

main:
  | e=top_expression EOF { e } 

/* Gestion du niveau racine avec ;; */
top_expression:
  | e=expression                                                                  { e }
  | LET m=motif EQ e1=expression SEMISEMI e2=top_expression                       { LetIn(m, e1, e2) }
  | LET REC x=binding EQ e1=expression SEMISEMI e2=top_expression                 { LetRec(x, e1, e2) }   
  | LET f=IDENT params=motif+ EQ e1=expression SEMISEMI e2=top_expression         { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetIn(MVar f, fun_expr, e2) }
  | LET REC f=IDENT params=motif+ EQ e1=expression SEMISEMI e2=top_expression     { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetRec(f, fun_expr, e2) }
  | TYPE t=IDENT EQ branches=branches_type SEMISEMI e=top_expression              { Type(t, branches, e) }
  | TYPE t=IDENT EQ PIPE branches=branches_type SEMISEMI e=top_expression         { Type(t, branches, e) }

/* Niveau 5b : Expressions générales (priorité basse) avec les tuples inclus */
expression:
  | e=expression_tuple { e }
  
  /* Structures let..in , let rec .. et fun , := et match .. with */
  | IF e1=expression THEN e2=expression_no_seq ELSE e3=expression_no_seq    { IfThenElse(e1, e2, e3) } 
  | LET m=motif EQ e1=expression IN e2=expression                           { LetIn(m, e1, e2) }
  | LET REC x=binding EQ e1=expression IN e2=expression                     { LetRec(x, e1, e2) }  
  | LET f=IDENT params=motif+ EQ e1=expression IN e2=expression             { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetIn(MVar f, fun_expr, e2) } 
  | LET REC f=IDENT params=motif+ EQ e1=expression IN e2=expression         { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetRec(f, fun_expr, e2) }
  | FUN params=motif+ ARROW e=expression                                    { List.fold_right (fun param body -> Fun(param, body)) params e }
  | FUNCTION branches=branches                                              { Function branches }
  | FUNCTION PIPE branches=branches                                         { Function branches }
  | e1=expression SEMI e2=expression                                        { LetIn(MWild, e1, e2) }
  | e1=application ASSIGN e2=expression                                     { Assign(e1, e2) }
  | MATCH e=expression WITH branches=branches                               { MatchWith(e, branches) }
  | MATCH e=expression WITH PIPE branches=branches                          { MatchWith(e, branches) }
  | TRY e=expression WITH branches=branches                                 { TryWith(e, branches) }
  | TRY e=expression WITH PIPE branches=branches                            { TryWith(e, branches) }

/* Niveau 5a : Expressions générales mais sans ... ; ... */
expression_no_seq:
  | e=expression_tuple { e }
  
  /* Structures let..in , let rec .. et fun , := et match .. with */
  | IF e1=expression THEN e2=expression_no_seq ELSE e3=expression_no_seq    { IfThenElse(e1, e2, e3) } 
  | LET m=motif EQ e1=expression IN e2=expression                           { LetIn(m, e1, e2) }
  | LET REC x=binding EQ e1=expression IN e2=expression                     { LetRec(x, e1, e2) }  
  | LET f=IDENT params=motif+ EQ e1=expression IN e2=expression             { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetIn(MVar f, fun_expr, e2) } 
  | LET REC f=IDENT params=motif+ EQ e1=expression IN e2=expression         { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetRec(f, fun_expr, e2) }
  | FUN params=motif+ ARROW e=expression                                    { List.fold_right (fun param body -> Fun(param, body)) params e }
  | FUNCTION branches=branches                                              { Function branches }
  | FUNCTION PIPE branches=branches                                         { Function branches }
  | e1=application ASSIGN e2=expression                                     { Assign(e1, e2) }
  | MATCH e=expression WITH branches=branches                               { MatchWith(e, branches) }
  | MATCH e=expression WITH PIPE branches=branches                          { MatchWith(e, branches) }
  | TRY e=expression WITH branches=branches                                 { TryWith(e, branches) }
  | TRY e=expression WITH PIPE branches=branches                            { TryWith(e, branches) }

/* Niveau 4c : Expressions générales (priorité basse) mais sans tuples */
expression_no_tuple:
  | e=expression_op { e } %prec PRIO_NO_TUPLE_EXPR_OP
  
  /* Structures let..in , let rec .. et fun , := et match .. with */
  | IF e1=expression THEN e2=expression_no_tuple_no_seq ELSE e3=expression_no_tuple_no_seq          { IfThenElse(e1, e2, e3) } 
  | LET m=motif EQ e1=expression IN e2=expression_no_tuple                                          { LetIn(m, e1, e2) }
  | LET REC x=binding EQ e1=expression IN e2=expression_no_tuple                                    { LetRec(x, e1, e2) }  
  | LET f=IDENT params=motif+ EQ e1=expression IN e2=expression_no_tuple                            { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetIn(MVar f, fun_expr, e2) } 
  | LET REC f=IDENT params=motif+ EQ e1=expression IN e2=expression_no_tuple                        { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetRec(f, fun_expr, e2) }
  | FUN params=motif+ ARROW e=expression_no_tuple                                                   { List.fold_right (fun param body -> Fun(param, body)) params e } 
  | FUNCTION branches=branches_no_tuple                                                             { Function branches }
  | FUNCTION PIPE branches=branches_no_tuple                                                        { Function branches }
  | e1=expression_no_tuple SEMI e2=expression_no_tuple                                              { LetIn(MWild, e1, e2) }
  | e1=application ASSIGN e2=expression_no_tuple                                                    { Assign(e1, e2) }
  | MATCH e=expression WITH branches=branches_no_tuple                                              { MatchWith(e, branches) }
  | MATCH e=expression WITH PIPE branches=branches_no_tuple                                         { MatchWith(e, branches) }
  | TRY e=expression WITH branches=branches_no_tuple                                                { TryWith(e, branches) }
  | TRY e=expression WITH PIPE branches=branches_no_tuple                                           { TryWith(e, branches) }

/* Niveau 4b : Expressions générales (priorité basse) mais sans tuples et sans ... ; ... */
expression_no_tuple_no_seq:
  | e=expression_op { e } %prec PRIO_NO_TUPLE_EXPR_OP
  
  /* Structures let..in , let rec .. et fun , := et match .. with */
  | IF e1=expression THEN e2=expression_no_tuple_no_seq ELSE e3=expression_no_tuple_no_seq          { IfThenElse(e1, e2, e3) } 
  | LET m=motif EQ e1=expression IN e2=expression_no_tuple                                          { LetIn(m, e1, e2) }
  | LET REC x=binding EQ e1=expression IN e2=expression_no_tuple                                    { LetRec(x, e1, e2) }  
  | LET f=IDENT params=motif+ EQ e1=expression IN e2=expression_no_tuple                            { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetIn(MVar f, fun_expr, e2) } 
  | LET REC f=IDENT params=motif+ EQ e1=expression IN e2=expression_no_tuple                        { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetRec(f, fun_expr, e2) }
  | FUN params=motif+ ARROW e=expression_no_tuple                                                   { List.fold_right (fun param body -> Fun(param, body)) params e } 
  | FUNCTION branches=branches_no_tuple                                                             { Function branches }
  | FUNCTION PIPE branches=branches_no_tuple                                                        { Function branches }
  | e1=application ASSIGN e2=expression_no_tuple                                                    { Assign(e1, e2) }
  | MATCH e=expression WITH branches=branches_no_tuple                                              { MatchWith(e, branches) }
  | MATCH e=expression WITH PIPE branches=branches_no_tuple                                         { MatchWith(e, branches) }
  | TRY e=expression WITH branches=branches_no_tuple                                                { TryWith(e, branches) }
  | TRY e=expression WITH PIPE branches=branches_no_tuple                                           { TryWith(e, branches) }

/* Niveau 4a : Tuples */
expression_tuple:
  | e=expression_op                                     { e }
  | e=expression_op COMMA es=expression_tuple_rest      { Tuple(e::es) }

expression_tuple_rest:
  | e=expression_tuple_last                             { [e] }
  | e=expression_op COMMA es=expression_tuple_rest      { e::es }

/* Sert pour les constructions let .. in, match .. with, etc qui concluent un tuple tout en excluant 
les :=, ; qui n'ont pas d'utilité dans ce cas et cela permet d'éviter les reduce/reduce conflict */
expression_tuple_last:
  | e=expression_op { e }
  
  /* Structures let..in , let rec .. et fun , := et match .. with*/
  | IF e1=expression THEN e2=expression_no_seq ELSE e3=expression_no_seq    { IfThenElse(e1, e2, e3) } 
  | LET m=motif EQ e1=expression IN e2=expression                           { LetIn(m, e1, e2) } %prec PRIO_TUPLE
  | LET REC x=binding EQ e1=expression IN e2=expression                     { LetRec(x, e1, e2) } %prec PRIO_TUPLE
  | LET f=IDENT params=motif+ EQ e1=expression IN e2=expression             { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetIn(MVar f, fun_expr, e2) } %prec PRIO_TUPLE
  | LET REC f=IDENT params=motif+ EQ e1=expression IN e2=expression         { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetRec(f, fun_expr, e2) } %prec PRIO_TUPLE
  | FUN params=motif+ ARROW e=expression                                    { List.fold_right (fun param body -> Fun(param, body)) params e } %prec PRIO_TUPLE
  | FUNCTION branches=branches                                              { Function branches }
  | FUNCTION PIPE branches=branches                                         { Function branches }
  | MATCH e=expression WITH branches=branches                               { MatchWith(e, branches) } 
  | MATCH e=expression WITH PIPE branches=branches                          { MatchWith(e, branches) } 
  | TRY e=expression WITH branches=branches                                 { TryWith(e, branches) }
  | TRY e=expression WITH PIPE branches=branches                            { TryWith(e, branches) }

/* Niveau 3 : Expression d'opérateurs */
expression_op:
  | e=application { e }

  /* Opérations arithmétiques */
  | e1=expression_op PLUS e2=expression_no_tuple        { ArOp(Add, e1, e2) }
  | e1=expression_op TIMES e2=expression_no_tuple       { ArOp(Mul, e1, e2) }
  | e1=expression_op MINUS e2=expression_no_tuple       { ArOp(Min, e1, e2) }
  | e1=expression_op DIVIDE e2=expression_no_tuple      { ArOp(Div, e1, e2) }
  | e1=expression_op MODULO e2=expression_no_tuple      { ArOp(Mod, e1, e2) }
  | MINUS e=expression_no_tuple                         { ArOp(Min, Cst 0, e) }
  
  /* Opérations booléennes */
  | e1=expression_op EQ e2=expression_no_tuple          { BlOp(Eq, e1, e2) }
  | e1=expression_op NEQ e2=expression_no_tuple         { BlOp(NEq, e1, e2) } 
  | e1=expression_op LESS_EQ e2=expression_no_tuple     { BlOp(LessEq, e1, e2) } 
  | e1=expression_op GREATER_EQ e2=expression_no_tuple  { BlOp(GreaterEq, e1, e2) } 
  | e1=expression_op LESS e2=expression_no_tuple        { BlOp(Less, e1, e2) } 
  | e1=expression_op GREATER e2=expression_no_tuple     { BlOp(Greater, e1, e2) } 
  | e1=expression_op AND e2=expression_no_tuple         { BlOp(And, e1, e2) } 
  | e1=expression_op OR e2=expression_no_tuple          { BlOp(Or, e1, e2) } 
  | NOT e=expression_op                                 { Not e } 

  /*Opérations sur les listes*/
  | e1=expression_op CONS e2=expression_op        { Cons(e1, e2) }

/* Niveau 2 : Application de "fonctions" */
application:
  | e=simple_expr                             { e }
  | e1=application e2=simple_expr             { App(e1, e2) } 
  | PRINT e=simple_expr                       { PrInt e }
  | REF e=simple_expr                         { Ref e }
  | EXCEPTION e=simple_expr                   { Exception e }
  | RAISE e=simple_expr                       { Raise e }
  | c=CONSTRUCTOR e=simple_expr               { Constructor(c, Some e) } 

/* Niveau 1 : Expressions simples (priorité maximale) */
simple_expr:
  | i=INT                                       { Cst i } 
  | b=BOOL                                      { Bool b } 
  | id=IDENT                                    { Ident id } 
  | LPAREN RPAREN                               { Unit }
  | NIL                                         { Nil }
  | LCROCHET e1=expression SEMI e2=liste        { Cons(e1, e2) }
  | LCROCHET e=expression RCROCHET              { Cons(e, Nil) }
  | DEREF e=simple_expr                         { Deref e } 
  | c=CONSTRUCTOR                               { Constructor(c, None) }
  | LPAREN e=expression RPAREN                  { e } 
  | BEGIN e=expression END                      { e } 

/* On les gardes pour let rec f = ... */
binding:
  | id=IDENT        { id } 
  | UNDERSCORE      { "_" }

/* Motifs */
motif_pipe:
  | m=motif                                 { [m] }
  | m=motif PIPE ms=motif_pipe              { m::ms }

motif:
  | m=motif_simple                          { m }
  | m=motif_simple COMMA ms=motif_tuple     { MTuple(m::ms) }
  | m1=motif_simple CONS m2=motif           { MCons(m1, m2) }
  | c=CONSTRUCTOR m=motif_simple            { MConstructor(c, Some m) }

motif_tuple:
  | m=motif_simple                          { [m] }
  | m=motif_simple COMMA ms=motif_tuple     { m::ms }

motif_list:
  | m=motif                                 { [m] }
  | m=motif SEMI ms=motif_list              { m::ms }

motif_simple:
  | i=INT                                   { MInt i }
  | b=BOOL                                  { MBool b }
  | id=IDENT                                { MVar id }
  | UNDERSCORE                              { MWild }
  | LPAREN RPAREN                           { MUnit }
  | NIL                                     { MNil }
  | EXCEPTION m=motif_simple                { MException m }
  | LCROCHET m=motif_list RCROCHET          { MList m }
  | c=CONSTRUCTOR                           { MConstructor(c, None) }
  | LPAREN m=motif RPAREN                   { m }

/* Branches des match .. with et try .. with */
branches:
  | m=motif_pipe ARROW e=expression    %prec PRIO_PIPE          { [(m, e)] }
  | m=motif_pipe ARROW e=expression PIPE rest=branches          { (m, e)::rest }

branches_no_tuple:
  | m=motif_pipe ARROW e=expression_no_tuple    %prec PRIO_PIPE             { [(m, e)] }
  | m=motif_pipe ARROW e=expression_no_tuple PIPE rest=branches_no_tuple    { (m, e)::rest }

/* Branches des type = ... | ... et on conserve l'arité de chaque constructeur (rq : on considère que C of int * int est d'arité 1 et prends pour argument un int * int) */
branches_type:
  | c=CONSTRUCTOR                                                       { [(c, 0)] }
  | c=CONSTRUCTOR OF constructor_type                                   { [(c, 1)] }
  | c=CONSTRUCTOR PIPE rest=branches_type                               { (c, 0)::rest }
  | c=CONSTRUCTOR OF constructor_type PIPE rest=branches_type           { (c, 1)::rest }

/* Les types des constructeurs (pour l'instant on ne les utilises pas) */
constructor_type:
  | IDENT                               { () }
  | LPAREN constructor_type RPAREN      { () }
  | IDENT TIMES constructor_type        { () }

/* Les listes */
liste:
  | a=expression RCROCHET           { Cons(a, Nil) }
  | a=expression SEMI e=liste       { Cons(a, e) }


%%