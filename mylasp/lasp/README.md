Lasp
=======================================================

For general information about the original project, see https://github.com/lasp-lang/lasp


# Important folders

## src
Contient les fichiers source de lasp.
Contient notamment lasp_app.erl qui définit ce que fera le node à son lancement.
Ce fichiers (lasp_app.erl) sera automatiquement remplacé par le fichier adéquat par le script LaunchExp.sh
Contient également lasp_convergence_measure.erl qui implémente certaines fonctions permettant de réaliser des mesures.

## Memoire
Ce dossier comporte 4 sous-dossier importants: MyScripts, AppsToLaunch, Mesures et Saved_measures.

### MyScripts
Ce dossier contient l'ensemble de mes scripts. 
Ceux-ci sont rendus le plus user-friendly possible et devraient normalement run facilement sur n'importe quelle machine.
Pensez à modifier votre adresse ip dans le fichier Memoire/AppsToLaunch/IpAddress.txt au préalable, vous pouvez évidemment utiliser 127.0.0.1 pour des tests locaux.


#### LaunchSet1.sh
Ce script permet de lancer le premier set d'expériences pour générer des fichiers de mesures.
Tout est automatisé et les fichiers d'outputs seront placés dans le dossier Memoire/Mesures. Les résultats (compte-rendu basé sur l'analyse des fichiers d'outputs) seront placés dans le dossier Memoire/Mesures/Results.
Ce premier set d'expérience concerne la création de 5 nodes qui vont générer des éléments et les ajouter dans un CRDT (awset) et mesurer le temps requis pour que le système ai convergé.
Plus de détails sur ces mesures, les paramètres utilisés, le nombre de valeurs générées, etc... Sont disponnibles directement dans les fichiers d'outputs.

Bien entendu, il en va de même pour les scripts LaunchSet2.sh, LaunchSet3.sh, etc... Qui lancent chacun un set d'expériences différent dont les informations sont décrites dans /Memoire/Saved_measures/measures_info. 


**IMPORTANT**: 
Avant de lancer tout script, pensez à écrire votre adresse IPV4 dans le fichier "/Memoire/AppsToLaunch/IpAddress.txt". Bien-entendu, si vous souhaitez uniquement run des simulations locales sans rejoindre le cluster avec des appareils à distance, vous pouvez simplement entrer "127.0.0.1".
 Les fichiers d'outputs et de résults sont placés dans le dossier "/Memoire/Mesures". Si des fichiers précédemment générés vous sont importants, pensez donc à les sauvegarder ailleurs avant de lancer une nouvelle exécution car le script commence automatiquement par nettoyer le dossier "/Memoire/Mesures". 


#### clean_mesures.sh
Ce script permet de supprimer les fichiers d'outputs qui ont été générés dans le dossier /Memoire/Mesures.
Il peut être lancé manuellement si vous le souhaitez mais, dans tous les cas, il est automatiquement exécuté lors de l'éxécution de nouvelles mesures.

#### analyse_static.sh
Les instructions de ce script sont automatiquement lancées à la suite d'un set d'expériences concernant des analyses statiques.
C'est-à-dire que pour LaunchSet1,2,..6 il s'agit d'expériences où des nodes génèrent des éléments dans un CRDT puis attendent et mesure le temps de convergence, il s'agit donc d'expériences statiques.
A la fin de l'expérience, les mesures sont automatiquement analysées. Mais si vous disposez déjà des mesures et voulez les analyser, par exemple en reprenant les mesures dans Memoire/Saved_measures, alors ce script peut vous intéresser.
Ce script permet de lancer l'analyse des fichiers d'outputs afin de générer des fichiers de résulstats qui sont automatiquement placés dans le dossier Results.

#### analyse_dynamic.sh
Les instructions de ce script sont automatiquement lancées à la suite d'un set d'expériences concernant des analyses dynamiques.
C'est-à-dire que pour LaunchSet7,8 il s'agit d'expériences où des nodes génèrent des éléments dans un CRDT  en continu durant toute l'expérience, il n'y a pas de moment de "pause" pendant lequel le CRDT se stabilise. C'est pourquoi je parle d'expériences dynamiques.
A la fin de l'expérience, les mesures sont automatiquement analysées. Mais si vous disposez déjà des mesures et voulez les analyser, par exemple en reprenant les mesures dans Memoire/Saved_measures, alors ce script peut vous intéresser.
Ce script permet de lancer l'analyse des fichiers d'outputs afin de générer des fichiers de résulstats qui sont automatiquement placés dans le dossier Results.

#### LaunchBasicNode
Il s'agit d'un script très simple qui lance un node lasp local (127.0.0.1) sans tâche particulière à effectuer, permettant donc à l'utilisateur d'intéragir directement dedans.

### AppsToLaunch
Ce dossier contient les expériences (sous forme de lasp_app.erl) à lancer par le script LaunchExp.sh
Autrement dit, pour lancer un set d'expériences différentes, il suffit de placer les bons fichiers dans ce dossier.
Les expériences réalisées ou encore à réalisées sont déjà préréglées et disponnibles dans le dossier /Memoire/Saved_measures/CorrectMeasures/measures_info mais cela sera détaillé plus bas.

### Mesures
Ce dossier contient les mesures qui viennent d'être réalisées (liées au dernier lancement du script).
A noter qu'il peut être judicieux de sauvegarder ces données avant de relancer le script LaunchExp car ce dernier supprime automatiquement les précédentes mesures afin de ne pas mélanger les outputs des différentes expériences.

### Saved_measures
Ce dossier a pour but de conserver les précédentes mesures qui ont déjà été correctement réalisées.
Le sous-dossier **measures_info** donne des informations concernant le type d'expérience mené pour chaque set de données. Il contient notamment une copie des fichiers lasp_app.erl utilisés pour les différents sets d'expériences.

Le sous-dossier **measures_datas** contient les données qui ont été sauvegardées pour de précédentes expériences. Les noms correspondent aux expériences reprises dans measures_info et coïncident avec les sets d'expériences des différents scripts. A noter que si ces expériences ont déjà été analysées, un dossier Results sera également présent donnant des informations statistiques.

