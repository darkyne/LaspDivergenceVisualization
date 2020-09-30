# Lasp Divergence Visualization


## RDV1 24-09-2020
Discussion et découverte approfondie du sujet. 
Description de Lasp et approche des CRDTs, de ses avantages, de ses utilisations et des projets liés.
Le mémoire consiste, si possible, à améliorer Lasp.
Lasp est fonctionnel et permet de faire du programme distribué de façon très facile car il converge toujours.
Mais Lasp n'offre pas, pour l'instant, d'outils permettant pour le programmeur de visualiser le degré de convergence de son système distribué.
Il sait que Lasp convergera et que les données seront cohérentes mais il ne sait pas combien de temps cela prendra, si un noeud a déjà convergé ou à l'inverse si un noeud est plus lent, etc...
L'idée serait donc d'ajouter cette fonctionnalité (de visualisation de la convergence des noeuds) sans impacter le coté fonctionnel.

## RDV2 30-09-2020
J'ai lu pas mal de documentations (pas d'articles détaillés sur les CRDTs pour l'instant, plutôt de la documentation technique, des API et des bouts de codes).
J'ai suivi quelques petits tutos erlang.
J'ai créé un premier script de mesures fonctionnel mais peu précis et probblement biaisé par ma machine.

Pour le lancer:
En ouvrant un terminal dans le dossier lasp, on peut entrer la commande
./myScript
Cela crée un certain nombre de lasp nodes runnant dans des terminaux différents.
Pour l'instant, on peut modifier le nombre de nodes manuellement dans myScript mais je ferai en sorte que ce soit un argument.
Les nodes sont automatiquement créés avec des noms "nodeX" où X est un nombre croissant partant de 1.
Le node1 mettra à jour une variable distribuée (pour l'instant un or_set en y mettant la valeur 5) et les autres nodes boucleront en query jusqu'à obtenir la bonne valeur, affichant le temps que cela leur a pris.
Il semblerait qu'en augmentant le nombre de node, le temps requis pour qu'ils aient convergé augmente légèrement. Mais ces mesures sont faites sur des nodes qui tournent tous en local sur une même machine du coup les performances de la machine (que je comparerai à du bruit vis-à-vis des mesures que je veux réaliser) prennent trop d'importance.
J'ai essayé de lancer des nodes et de mesurer le temps qu'ils mettent pour exécuter de bêtes opérations (non-liées à leur convergence) et on voit effectivement qu'au plus il y a de noeuds au plus c'est lent. Il s'agit donc en partie d'une mesure des performances de ma machine (lié à la quantité de RAM, fréquence du processeur, nombre de coeurs du CPU, threads logiques, etc...).



## RDV3 Date à définir
