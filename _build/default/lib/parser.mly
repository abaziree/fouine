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

/* PARTIE 3 : Associativités et priorités */
%nonassoc IN ELSE ARROW
%right SEMI
%nonassoc ASSIGN
%left OR
%left AND
%nonassoc NOT
%left EQ NEQ LESS GREATER LESS_EQ GREATER_EQ
%left PLUS MINUS
%left TIMES DIVIDE MODULO

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
  | LET x=binding EQ e=expression SEMISEMI                                        { LetIn(x, e, Unit) }
  | LET x=binding EQ e1=expression SEMISEMI e2=top_expression                     { LetIn(x, e1, e2) } 
  | LET f=IDENT params=binding+ EQ e1=expression SEMISEMI e2=top_expression       { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetIn(f, fun_expr, e2) }
  | LET REC f=IDENT params=binding+ EQ e1=expression SEMISEMI e2=top_expression   { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetRec(f, fun_expr, e2) }

binding:
  | id=IDENT        { id } 
  | UNDERSCORE      { "_" }
  | LPAREN RPAREN   { "()" }

/* Niveau 3 : Expressions générales (priorité basse) */
expression:
  | e=application { e } 
  
  /* Opérations arithmétiques */
  | e1=expression PLUS e2=expression        { ArOp(Add, e1, e2) } 
  | e1=expression TIMES e2=expression       { ArOp(Mul, e1, e2) }
  | e1=expression MINUS e2=expression       { ArOp(Min, e1, e2) } 
  | e1=expression DIVIDE e2=expression      { ArOp(Div, e1, e2) } 
  | e1=expression MODULO e2=expression      { ArOp(Mod, e1, e2) } 
  | MINUS e=expression                      { ArOp(Min, Cst 0, e) } 
  
  /* Opérations booléennes */
  | e1=expression EQ e2=expression          { BlOp(Eq, e1, e2) }
  | e1=expression NEQ e2=expression         { BlOp(NEq, e1, e2) } 
  | e1=expression LESS_EQ e2=expression     { BlOp(LessEq, e1, e2) } 
  | e1=expression GREATER_EQ e2=expression  { BlOp(GreaterEq, e1, e2) } 
  | e1=expression LESS e2=expression        { BlOp(Less, e1, e2) } 
  | e1=expression GREATER e2=expression     { BlOp(Greater, e1, e2) } 
  | e1=expression AND e2=expression         { BlOp(And, e1, e2) } 
  | e1=expression OR e2=expression          { BlOp(Or, e1, e2) } 
  | NOT e=expression                        { Not e } 
  
  /* Structures let..in et let rec .. et fun */
  | IF e1=expression THEN e2=expression ELSE e3=expression                  { IfThenElse(e1, e2, e3) } 
  | LET x=binding EQ e1=expression IN e2=expression                         { LetIn(x, e1, e2) } 
  | LET f=IDENT params=binding+ EQ e1=expression IN e2=expression           { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetIn(f, fun_expr, e2) } 
  | LET REC f=IDENT params=binding+ EQ e1=expression IN e2=expression       { let fun_expr = List.fold_right (fun param body -> Fun(param, body)) params e1 in LetRec(f, fun_expr, e2) }
  | FUN params=binding+ ARROW e=expression                                  { List.fold_right (fun param body -> Fun(param, body)) params e } 
  | e1=expression SEMI e2=expression                                        { LetIn("_", e1, e2) }
  | e1=application ASSIGN e2=expression                                     { Assign(e1, e2) }

/* Niveau 2 : Application de fonction (associative à gauche) */
application:
  | e=simple_expr                   { e } 
  | e1=application e2=simple_expr   { App(e1, e2) } 
  | PRINT e=simple_expr             { PrInt e }
  | REF e=simple_expr               { Ref e }
  | DEREF e=simple_expr             { Deref e }

/* Niveau 1 : Expressions simples (priorité maximale) */
simple_expr:
  | i=INT                           { Cst i } 
  | b=BOOL                          { Bool b } 
  | id=IDENT                        { Ident id } 
  | LPAREN RPAREN                   { Unit }
  | LPAREN e=expression RPAREN      { e } 
  | BEGIN e=expression END          { e } 

%%