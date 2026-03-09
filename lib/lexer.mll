{
  (* Prélude du fichier *)
  open Parser
}

(* Définitions d'expressions régulières *)
let chiffre = ['0'-'9']
let nombre = chiffre+
let minuscule = ['a'-'z']
let majuscule = ['A'-'Z']
let lettre = minuscule | majuscule
let ident = minuscule (lettre | chiffre | '_')*
let constructor_id = majuscule (lettre | chiffre | '_')*

rule token = parse    
  | [' ' '\t' '\n']       { token lexbuf }    (* On saute les blancs et les tabulations *)
  | eof                   { EOF }             (* End Of File *)
  | '+'                   { PLUS }
  | '*'                   { TIMES }
  | '-'                   { MINUS }
  | '/'                   { DIVIDE }
  | "mod"                 { MODULO }
  | '('                   { LPAREN }
  | ')'                   { RPAREN }
  | nombre as s           { INT (int_of_string s) }
  | "if"                  { IF }
  | "then"                { THEN }
  | "else"                { ELSE }
  | "true"                { BOOL true }
  | "false"               { BOOL false }
  | "="                   { EQ }
  | "<>"                  { NEQ }
  | "<="                  { LESS_EQ }
  | ">="                  { GREATER_EQ }
  | '<'                   { LESS }
  | '>'                   { GREATER }
  | "&&"                  { AND }
  | '['                   { LCROCHET }
  | ']'                   { RCROCHET }
  | "[]"                  { NIL }
  | "::"                  { CONS }
  | "||"                  { OR }
  | "not"                 { NOT }
  | "begin"               { BEGIN }
  | "end"                 { END }
  | "prInt"               { PRINT }
  | "let"                 { LET }
  | "rec"                 { REC }
  | "in"                  { IN }
  | "fun"                 { FUN }
  | "function"            { FUNCTION }
  | "->"                  { ARROW }
  | ";;"                  { SEMISEMI }
  | '_'                   { UNDERSCORE }
  | "ref"                 { REF }
  | ":="                  { ASSIGN }
  | '!'                   { DEREF }
  | ';'                   { SEMI }
  | "match"               { MATCH }
  | "with"                { WITH }
  | '|'                   { PIPE }
  | ','                   { COMMA }
  | "try"                 { TRY }
  | "raise"               { RAISE }
  | 'E'                   { EXCEPTION }
  | "type"                { TYPE }
  | "of"                  { OF }
  | ident as id           { IDENT id }
  | constructor_id as id  { CONSTRUCTOR id }