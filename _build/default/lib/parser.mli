
(* The type of tokens. *)

type token = 
  | UNDERSCORE
  | TIMES
  | THEN
  | SEMISEMI
  | SEMI
  | RPAREN
  | REF
  | REC
  | PRINT
  | PLUS
  | OR
  | NOT
  | NEQ
  | MODULO
  | MINUS
  | LPAREN
  | LET
  | LESS_EQ
  | LESS
  | INT of (int)
  | IN
  | IF
  | IDENT of (string)
  | GREATER_EQ
  | GREATER
  | FUN
  | EQ
  | EOF
  | END
  | ELSE
  | DIVIDE
  | DEREF
  | BOOL of (bool)
  | BEGIN
  | ASSIGN
  | ARROW
  | AND

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val main: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Expressions.expr)
