#Ce dossier contient mes notes personnelles rédigées chaque semaine concernant mon avancée.

# Les RDV
Chaque semaine, j'ai écrit un compte-rendu de ce que je réalisais chaque jour, progressivement.
Chaque RDV s'est donc en partie basé sur des notes disponnibles dans le fichier notes.txt correspondant.
Ces notes contiennent également un résumé de ce qui a été débattu pendant le rdv hebdomadaire.


## RDV1 24-09-2020 15h (Teams)
voir /RDV1/notes.txt pour plus de détails.
Discussion et découverte approfondie du sujet. 
Description de Lasp et approche des CRDTs, de ses avantages, de ses utilisations et des projets liés.
Le mémoire consiste, si possible, à améliorer Lasp.
Lasp est fonctionnel et permet de faire du programme distribué de façon très facile car il converge toujours.
Mais Lasp n'offre pas, pour l'instant, d'outils permettant pour le programmeur de visualiser le degré de convergence de son système distribué.
Il sait que Lasp convergera et que les données seront cohérentes mais il ne sait pas combien de temps cela prendra, si un noeud a déjà convergé ou à l'inverse si un noeud est plus lent, etc...
L'idée serait donc d'ajouter cette fonctionnalité (de visualisation de la convergence des noeuds) sans impacter le coté fonctionnel.

## RDV2 30-09-2020 16h (LLN)
voir /RDV2/notes.txt pour plus de détails
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

Pour la semaine prochaine: 
Lire des articles sur les CRDTs.
Faire run des nodes Lasp en dehors de mon ordinateur.

## RDV3 07-10-2020 16h (LLN)

Articles lus:
Tout sauf le master thesis sur Lasp on Grisp.
J'ai également visualisé le MOOC fournis (super intéressant !).

J'ai parcouru une partie du code de Lasp afin de regarder (même si pas tout compris encore) l'implémentation des fonctions détaillées dans les articles/vidéos.
Je dispose désormais d'un accès SSH vers une VM qui m'est attribuée.

Voir /RDV3/notes.txt pour mes notes de lectures, remarques et questions.


## RDV4 14-10-2020 16h (LLN)
Mise au propre de mes questions concernant les articles lus précédemment.
Explication du ORSWOT.
Problèmes techniques pour cluster des nodes remotes.
Première roadmap.

Voir /RDV4/notes.txt pour mes notes de lectures, remarques et questions.


## RDV5 20-10-2020 14h (Teams)
Lecture complète de tous les fichiers codes de lasp (fichiers présents dans le dossier src de lasp, pas tous les fichiers des différentes librairies utilisées).
Résolution de mon problème de clustering (partage du erlang.cookie).
Installation de lasp sur raspberry pi.
Communications locales entre PC et raspberry pi.

Voir /RDV5/notes.txt pour mes notes de lectures, remarques et questions.


## RDV6 27-10-2020 14h (Teams)
Mise au point d'un algorithme de mesure avec le ORSWOT (awset).
Implémentation script qui lance les mesures, cas add elements et cas remove elements.

voir /RDV6/notes.txt pour mes notes de lectures, remarques et questions.

## RDV7 3-11-2020 14 (Teams)
Résolution de mon problème de synchronisation et d'orchestrage.
Mise au point d'un script totalement automatisé (capable de tourner toute la nuit pour produire des outputs).
Mesure réseau et nombre de messages.

Voir /RDV7/notes.txt pour mes notes de lectures, remarques et questions.


## RDV8 10-11-2020 14 (Teams)
Script de mesures amélioré.
Scritp d'analyse achevé.
Génération de mesures et d'analyse pour les cas:
5nodes: add 10,100,1000 et remove 10,100,1000
10nodes: add 10,100,1000 et remove 10,100,1000
20nodes: add 10,100 et remove 10,100
Accès à un serveur UCL 10 coeurs 10Go RAM.
Mise au point d'un algorithme capable de run des mesures en tâche de fond.
En cours: comprendre comment faire pour lancer cela en tâche de fond.


## RDV9 17-11-2020 14 (Teams)
Fin implémentation tâche dynamique (add/remove/dump to file).
Lancement de mesures sur la VM INGI.
Resolution problème lié au lancement sur VM.
Mesures dynamiques réalisées pour 5 et 10 nodes.


## RDV10 24-11-2020 14 (Teams)
Fin implémentation tâche continue en fond.
Ce système de mesures continues peut désormais s'adapter (si des nodes sont ajoutés, retirés ou tués).
launchContinuousMeasure(Period) permet de mettre à jour de façon continues les mesures de convergence.
Les nodes peuvent accéder à différentes méthodes permettant de visualiser ces dernières mesures.
Remarque: 
mesure pour ajouter un simple élément (un chiffre: 5) dans:
-un state_awset vide: environ 25 ms (15 à 40ms)
-un state_orset vide: environ 30ms (20 à 40ms)
-un gcounter à 0: environ 20 ms (10 à 30ms)


## RDV11 01-12-2020 14 (Teams)
Création poster.
Tracing du add pour comprendre ce qui le rend si lent.
Mise au point d'une API pour modifier le temps de convergence.