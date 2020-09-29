# Lasp Divergence Visualization


## RDV1 24-09-2020


## RDV2 30-09-2020
J'ai lu pas mal de documentations (pas d'articles détaillés sur les CRDTs pour l'instant, plutôt de la documentation technique, des API et des bouts de codes).
J'ai suivi quelques petits tutos erlang.
J'ai créé un premier script de mesures fonctionnel mais peu précis et probblement biaisé par ma machine.

Pour le lancer:
En ouvrant un terminal dans le dossier lasp, on peut entrer la commande
./myScript
Cela crée un certain nombre de lasp nodes runnant dans des terminaux différents.
Pour l'instant, on peut modifier le nombre de nodes manuelle dans myScript mais je ferai en sorte que ce soit un argument.
Les nodes sont automatiquement créés avec des noms "nodeX" où X est un nombre croissant partant de 1.
Le node1 mettra à jour une variable distribuée (pour l'instant un or_set en y mettant la valeur 5) et les autres nodes boucleront en query jusqu'à obtenir la bonne valeur.


## RDV3 Date à définir
