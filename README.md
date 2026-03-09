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

Nous avons implémenté les expressions arithmétiques, les opérateurs booléns, la fonction prInt, les déclarations des LetIn, les fonctions (récursives ou pas), les exceptions (seulement l'exception E of int), les listes, les options, les tuples et les motifs. 


## Les expressions arithmétiques et opérateurs booléens

On a utilisé une fonction pour alléger la fonction d'affichage qui associe à chaque opérateur lui-même comme chaîne de caractères. 


## Les exceptions

Elles ont été implémentées comme valeur, puisque nous n'avons pas fait de continuation.


## Les listes

Pour implémenter les listes, il a été décidé de procéder de la manière suivante : soit on parse la liste vide (qui contient une expression, donc potentiellement une autre liste), soit un singleton, soit on va chercher une liste d'expressions séparées par des points-virgules, qui se conclut par ]. Ainsi, lorsqu'on entame une liste de plus de 2 éléments, on bascule dans le niveau "liste", qui nécessite un ] pour finir de parser. 

