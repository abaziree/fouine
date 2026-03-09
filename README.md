## Compilation et execution

Les commandes ci-dessous sont à exécuter dans le répertoire principal, qui est au-dessus de bin/ et lib/.

pour (re)compiler, lancer
```
dune build
```

pour executer le programme, lancer
```
dune exec bin/fouine.exe
```

Entrez ensuite un programme OCaml

On vous conseille d'exécuter une fois la commande
```
ln -s _build/default/bin/fouine.exe fouine
```
pour ne pas avoir à saisir le `_build/default/main.exe`

Après quoi vous pouvez
- taper `./fouine` pour lancer l'exécutable et saisir une expression au clavier
- taper `./fouine test/basic.ml` pour lancer fouine sur le fichier basic.ml

## Ce que nous avons fait :

Nous avons implémenté les expressions arithmétiques, les opérateurs booléns, la fonction prInt, les déclarations des LetIn, les fonctions (récursives ou pas), les exceptions (seulement l'exception E of int), les références, les listes, les options, les tuples, les motifs et les types (mais sans conserver leur vrai type pour l'instant ; par exemple un C of int * int sera juste retenu comme un constructeur unaire [car tout constructeur non constant est unaire] mais on ne retiendra pas le int * int)


## Les expressions arithmétiques et opérateurs booléens (Rendu0 de Aurélien)

Ils sont concaténés dans les types ArOp et BlOp. Cela simplifie autant l'évaluation que l'affichage !
On a utilisé une fonction pour alléger la fonction d'affichage qui associe à chaque opérateur lui-même comme chaîne de caractères. 

## Les LetIn et LetRec (Aurélien)

Le LetIn fonctionne avec les motifs mais pas LetRec pour éviter au parsing les constructions du type "let rec (f,g) = (5,6)".

## Les références (Aurélien)

Les références fonctionnent avec un tas général implémenté par un tableau OCaml.


## Les exceptions (Isaure)

Elles ont été implémentées comme valeur, puisque nous n'avons pas fait de continuation.


## Les listes (Isaure)

Pour implémenter les listes, il a été décidé de procéder de la manière suivante : soit on parse la liste vide (qui contient une expression, donc potentiellement une autre liste), soit un singleton, soit on va chercher une liste d'expressions séparées par des points-virgules, qui se conclut par ]. Ainsi, lorsqu'on entame une liste de plus de 2 éléments, on bascule dans le niveau "liste", qui nécessite un ] pour finir de parser. 

## Les tuples et pattern matching (Aurélien)

La principale difficulté sur les tuples était le parsing. Cela a résulté en une stratification précise des expressions et de ce qu'il est possible d'inclure dans un tuple.
Le pattern matching fonctionne en stockant les motifs du paterne et lors de l'évaluation, on recherche le premier paterne qui convient et on suit sa flèche vers la suite des instructions à éxécuter.

## Les types (Aurélien et Isaure)

Puisque le typage n'est pas implémenté, le choix a été fait de construire les déclarations de type mais sans conserver les types des nouveaux constructeurs. On conserve uniquement leur arité à savoir 0 ou 1.

