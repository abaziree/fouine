open Lib

let _DEBUG = ref false

let _SHOWSRC = ref false

(* "incantations" qu'il n'est pas nécessaire de comprendre dans un premier
   temps : on récupère l'entrée, dans un fichier ou sur le clavier *)
let nom_fichier = ref ""

let recupere_entree () =
  let opt_list = [
    ("-showsrc", Arg.Set _SHOWSRC, "Affiche le programme Fouine fourni sans l'exécuter");
     "-debug", Arg.Set _DEBUG, "utilise -showsrc et évalue le programme"
  ] in 
  let usage = "pour fouiner. Utilisation : ./fouine <fichier> [options]" in

  Arg.parse (* ci-dessous les 3 arguments de Arg.parse : *)
    opt_list (* la liste des options, vide *)
    (fun s -> nom_fichier := s) (* la fonction a déclencher lorsqu'on récupère un string qui n'est pas une option : ici c'est le nom du fichier, et on stocke cette information dans la référence nom_fichier *)
    usage; (* le message d'accueil, qui est vide *)
  try
    let where_from = match !nom_fichier with
      | "" -> stdin
      | s -> open_in s in
    let lexbuf = Lexing.from_channel where_from in
    let parse () = Parser.main Lexer.token lexbuf in
    parse () 
  with 
  | Parsing.Parse_error -> 
      Printf.eprintf "Syntax Error\n"; 
      exit 1
  | e -> 
      Printf.eprintf "Input problem: %s\n" (Printexc.to_string e); 
      exit 1

(* le traitement d'une expression en entrée *)   
let execute e =
  (* Option -showsrc : affiche seulement le code source *)
  if !_SHOWSRC && not !_DEBUG then (
    print_string "====== Code source ======\n";
    Affichage.affiche_src e;
    print_newline()
  )

  (* Option -debug : affiche arbre syntaxique + exécute + affiche résultat *)
  else if !_DEBUG then (
    (* Affiche l'arbre syntaxique *)
    print_string "====== Arbre syntaxique ======\n";
    Affichage.affiche_expr e;
    print_newline();
    print_newline();
    
    (* Affiche le code source *)
    print_string "====== Code source ======\n";
    Affichage.affiche_src e;
    print_newline();
    print_newline();

    
    (* Évalue et affiche la valeur de fin *)
    print_string "====== Exécution ======\n";
    flush stdout
  );


  begin
    try
      if not !_SHOWSRC || !_DEBUG then (
        let v = Expressions.eval e in (* on évalue e *)
        if (!_DEBUG) then (
          print_string "Valeur finale: " ; Affichage.affiche_val v;
          print_newline());
      )
    with
    | Expressions.DivisionParZero ->
        Printf.eprintf "Error: Division by zero\n";
        exit 1
    | Expressions.VariableNonDefinie x ->
        Printf.eprintf "Error: Undefined variable '%s'\n" x;
        exit 1
    | Expressions.ErreurDeType msg ->
        Printf.eprintf "Typing error: %s\n" msg;
        exit 1
    | Expressions.ConditionNonBooleenne ->
        Printf.eprintf "Error: The condition of an 'if' must be a boolean\n";
        exit 1
    | Expressions.ApplicationNonFonction ->
        Printf.eprintf "Error: Attempt to apply to a value that is not a function\n";
        exit 1
    | Expressions.TasPlein ->
        Printf.eprintf "Error: Heap full, no more memory available\n";
        exit 1
    | Expressions.AdresseInvalide addr ->
        Printf.eprintf "Error: Invalid address %d\n" addr;
        exit 1
    | Expressions.FiltrageSansCorrespondance ->
        Printf.eprintf "Error: Filtering failed (incomplete match ?)\n";
        exit 1
  end

(* la fonction principale *)
let run () =
  try
    let saisie = recupere_entree () in
    execute saisie; 
    flush stdout
  with e -> raise e  (* <-- en cas d'exception *)


let _ = run ()
