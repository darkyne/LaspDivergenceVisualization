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

#### analyse.sh
Ce script permet de lancer l'analyse des fichiers d'outputs afin de générer des fichiers de résulstats qui sont automatiquement placés dans le dossier Results.
A noter qu'il est conseillé d'utiliser ce script dans un environnement séparé afin d'éviter tout risque de corrompre de précédents résultats. C'est pourquoi il se trouve dans un dossier à part (appelé analyse).

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

