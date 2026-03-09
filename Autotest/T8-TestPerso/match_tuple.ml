let valeur = (3, 4) in
match valeur with
| (0, _) -> prInt 0
| (x, y) -> prInt (x + y)
