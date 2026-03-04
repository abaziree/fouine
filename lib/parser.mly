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
%token FUN ARROW
%token REF ASSIGN DEREF
%token SEMI
%token COMMA 
%token MATCH WITH PIPE

/* Token de priorités */
%token PRIO_PIPE
%token PRIO_TUPLE
%token BOTTOM

/* PARTIE 3 : Associativités et priorités */
%nonassoc IN ELSE PRIO_PIPE
%right PIPE
%nonassoc PRIO_TUPLE
%right ARROW
%right SEMI
%nonassoc ASSIGN
%left OR
%left AND
%nonassoc NOT
%left EQ NEQ LESS GREATER LESS_EQ GREATER_EQ
%left PLUS MINUS
%left TIMES DIVIDE MODULO
%nonassoc BOTTOM

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
  (*| LET x=binding EQ e=expression SEMISEMI                                        { LetIn(x, e, Unit) }*)
  | LET m=motif EQ e1=expression SEMISEMI e2=top_expression                       { LetIn(m, e1, e2) }
  | LET REC x=binding EQ e1=expression SEMISEMI e2=top_expression                 { LetRec(x, e1, e2) }   
  | LET f=IDENT params=motif+ EQ e1=expression SEMISEMI e2=top_expression         { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetIn(MVar f, fun_expr, e2) }
  | LET REC f=IDENT params=motif+ EQ e1=expression SEMISEMI e2=top_expression     { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetRec(f, fun_expr, e2) }

/* Niveau 5 : Expressions générales (priorité basse) avec les tuples inclus */
expression:
  | e=expression_tuple { e }
  
  /* Structures let..in , let rec .. et fun , := et match .. with*/
  | IF e1=expression THEN e2=expression ELSE e3=expression                  { IfThenElse(e1, e2, e3) } 
  | LET m=motif EQ e1=expression IN e2=expression                           { LetIn(m, e1, e2) }
  | LET REC x=binding EQ e1=expression IN e2=expression                     { LetRec(x, e1, e2) }  
  | LET f=IDENT params=motif+ EQ e1=expression IN e2=expression             { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetIn(MVar f, fun_expr, e2) } 
  | LET REC f=IDENT params=motif+ EQ e1=expression IN e2=expression         { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetRec(f, fun_expr, e2) }
  | FUN params=motif+ ARROW e=expression                                    { List.fold_right (fun param body -> Fun(param, body)) params e } 
  | e1=expression SEMI e2=expression                                        { LetIn(MWild, e1, e2) }
  | e1=application ASSIGN e2=expression                                     { Assign(e1, e2) }
  | MATCH e=expression WITH branches=branches                               { MatchWith(e, branches) }

/* Niveau 4b : Expressions générales (priorité basse) mais sans tuples */
expression_no_tuple:
  | e=expression_op { e } %prec BOTTOM
  
  /* Structures let..in , let rec .. et fun , := et match .. with */
  | IF e1=expression THEN e2=expression_no_tuple ELSE e3=expression_no_tuple          { IfThenElse(e1, e2, e3) } 
  | LET m=motif EQ e1=expression IN e2=expression_no_tuple                            { LetIn(m, e1, e2) }
  | LET REC x=binding EQ e1=expression IN e2=expression_no_tuple                      { LetRec(x, e1, e2) }  
  | LET f=IDENT params=motif+ EQ e1=expression IN e2=expression_no_tuple              { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetIn(MVar f, fun_expr, e2) } 
  | LET REC f=IDENT params=motif+ EQ e1=expression IN e2=expression_no_tuple          { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetRec(f, fun_expr, e2) }
  | FUN params=motif+ ARROW e=expression_no_tuple                                     { List.fold_right (fun param body -> Fun(param, body)) params e } 
  | e1=expression_no_tuple SEMI e2=expression_no_tuple                                { LetIn(MWild, e1, e2) }
  | e1=application ASSIGN e2=expression_no_tuple                                      { Assign(e1, e2) }
  | MATCH e=expression WITH branches=branches_no_tuple                                { MatchWith(e, branches) }

/* Niveau 4a : Tuples */
expression_tuple:
  | e=expression_op                                     { e }
  | e=expression_op COMMA es=expression_tuple_rest      { Tuple(e::es) }

expression_tuple_rest:
  | e=expression_tuple_last                             { [e] }
  | e=expression_op COMMA es=expression_tuple_rest      { e::es }

expression_tuple_last:
  | e=expression_op { e }
  
  /* Structures let..in , let rec .. et fun , := et match .. with*/
  | IF e1=expression THEN e2=expression ELSE e3=expression                  { IfThenElse(e1, e2, e3) } %prec PRIO_TUPLE
  | LET m=motif EQ e1=expression IN e2=expression                           { LetIn(m, e1, e2) } %prec PRIO_TUPLE
  | LET REC x=binding EQ e1=expression IN e2=expression                     { LetRec(x, e1, e2) } %prec PRIO_TUPLE
  | LET f=IDENT params=motif+ EQ e1=expression IN e2=expression             { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetIn(MVar f, fun_expr, e2) } %prec PRIO_TUPLE
  | LET REC f=IDENT params=motif+ EQ e1=expression IN e2=expression         { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetRec(f, fun_expr, e2) } %prec PRIO_TUPLE
  | FUN params=motif+ ARROW e=expression                                    { List.fold_right (fun param body -> Fun(param, body)) params e } %prec PRIO_TUPLE
  | MATCH e=expression WITH branches=branches                               { MatchWith(e, branches) } 

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


/* Niveau 2 : Application de fonction (associative à gauche) */
application:
  | e=simple_expr                   { e } 
  | e1=application e2=simple_expr   { App(e1, e2) } 
  | PRINT e=simple_expr             { PrInt e }
  | REF e=simple_expr               { Ref e }
  | DEREF e=simple_expr             { Deref e }

/* Niveau 1 : Expressions simples (priorité maximale) */
simple_expr:
  | i=INT                             { Cst i } 
  | b=BOOL                            { Bool b } 
  | id=IDENT                          { Ident id } 
  | LPAREN RPAREN                     { Unit }
  | LPAREN e=expression RPAREN        { e } 
  | BEGIN e=expression END            { e } 

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
  | m=motif_simple COMMA ms=motif_suite     { MTuple(m::ms) }

motif_suite:
  | m=motif_simple                          { [m] }
  | m=motif_simple COMMA ms=motif_suite     { m::ms }

motif_simple:
  | i=INT                                   { MInt i }
  | b=BOOL                                  { MBool b }
  | id=IDENT                                { MVar id }
  | UNDERSCORE                              { MWild }
  | LPAREN RPAREN                           { MUnit }
  | LPAREN m=motif RPAREN                   { m }

/* Branches des match .. with */
branches:
  | PIPE m=motif_pipe ARROW e=expression    %prec PRIO_PIPE    { [(m, e)] }
  | PIPE m=motif_pipe ARROW e=expression rest=branches         { (m, e)::rest }

branches_no_tuple:
  | PIPE m=motif_pipe ARROW e=expression_no_tuple    %prec PRIO_PIPE        { [(m, e)] }
  | PIPE m=motif_pipe ARROW e=expression_no_tuple rest=branches_no_tuple    { (m, e)::rest }



%%