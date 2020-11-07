Lasp
=======================================================

For general information about the original project, see https://github.com/lasp-lang/lasp

#My Scripts
###LaunchExp.sh
Ce script permet de lancer un set d'expériences pour générer des mesures.
Les dossiers et fichiers d'outputs seront automatiquement placés dans le dossier /Memoire/Mesures.
Le script lancera un certain nombre d'expériences différentes, ces expériences (les fichiers lasp_app.erl) doivent être placés au préalable dans le dossier /Memoire/AppsToLaunch.
Le script lancera un certain nombre de nodes qui exécuteront la première expérience avec un certain nombre d'itérations (prédéfini), générant tous les fichiers d'outputs avant de passer à l'expérience suivante (expérience 2), etc...
Le nombre de nodes à simuler sur la machine, le nombre d'itérations souhaité pour chaque expérience, le nombre d'expériences différentes et la durée limite pour chaque expérience peuvent être modifiés dans les premiers premières lignes du script. 
A noter que selon l'appareil sur lequel est lancé le script, il peut être nécessaire de modifier l'addresse IP utilisées via la variable correspondante.
Si vous souhaitez réaliser de simples mesures locales afin de tester l'exécution de mon script, vous pouvez évidemment utiliser l'adresse "127.0.0.1".
Par ailleurs, il est également nécessaire de réécrire sourcePath et destinationPath de façon cohérente avec l'emplacement dans lequel se trouve votre dossier lasp.
Veuillez lire la partie **Exemple concret** ci-dessous si vous souhaitez plus d'information sur ce script.



###clean_mesures.sh
Ce script permet de supprimer les fichiers d'outputs qui ont été générés dans le dossier /Memoire/Mesures.

###analyse.sh
Ce script permet de lancer l'analyse des fichiers d'outputs afin de générer des fichiers de résulstats qui sont automatiquement placés dans le dossier Results.
A noter qu'il est conseillé d'utiliser ce script dans un environnement séparé afin d'éviter tout risque de corrompre de précédents résultats. C'est pourquoi il se trouve dans un dossier à part (appelé analyse).

#Important folders

##src
Contient les fichiers source de lasp.
Contient notamment lasp_app.erl qui définit ce que fera le node à son lancement.
Ce fichiers (lasp_app.erl) sera automatiquement remplacé par le fichier adéquat par le script LaunchExp.sh
Contient également lasp_convergence_measure.erl qui implémente certaines fonctions permettant de réaliser des mesures.

##Memoire
Ce dossier comporte 3 sous-dossier importants:

###AppsToLaunch
Ce dossier contient les expériences (sous forme de lasp_app.erl) à lancer par le script LaunchExp.sh
Autrement dit, pour lancer un set d'expériences différentes, il suffit de placer les bons fichiers dans ce dossier.
Les expériences réalisées ou encore à réalisées sont déjà préréglées et disponnibles dans le dossier /Memoire/Saved_measures/CorrectMeasures/measures_info mais cela sera détaillé plus bas.

###Mesures
Ce dossier contient les mesures qui viennent d'être réalisées (liées au dernier lancement du script).
A noter qu'il peut être judicieux de sauvegarder ces données avant de relancer le script LaunchExp car ce dernier supprime automatiquement les précédentes mesures afin de ne pas mélanger les outputs des différentes expériences.

###Saved_measures
Ce dossier a pour but de conserver les précédentes mesures qui ont déjà été correctement réalisées. Pour cela, il faut regarder dans le sous-dossier CorrectMeasures.
Le sous-dossier **measures_info** donne des informations concernant le type d'expérience mené pour chaque set de données. Il contient notamment le fichier lasp_app.erl utilisé pour l'expérience.
Autrement dit, pour relancer un set d'expériences (par exemple le premier), il suffit d'aller dans /Memoire/Saved_measured/CorrectMeasures/measures_info/info_saved_1 et de copier coller tout le contenu vers /Memoire/AppsToLaunch puis de lancer le script LaunchExp.sh. Cela chargera progressivement les fichiers lasp_app.erl et réalisera automatiquement les expériences. A noter que cela peut, selon le type d'expérience, prendra de nombreuses heures dû au nombre d'itération élevé par défaut.

Le sous-dossier **measures_datas** contient les données qui ont été sauvegardées pour de précédentes expériences. Les noms correspondent aux expériences repreises dans measures_info. A noter que si ces expériences ont  déjà été analysées, un dossier Results sera également présent donnant des informations statistiques.


#Exemple concret

Prenons un exemple concret de lancement du script de mesures:
Les expériences que vous voulez lancer doivent être placés au préalable dans le dossier /Memoire/AppsToLaunch. 
Supposons que vous voulez lancer, par exemple, le 3ème set d'expérience, il s'agit d'une expérience où 10 nodes vont add des éléments et attendre que le système ai convergé.
Allez alors dans le dossier /Memoire/Saved_measures/CorrectMeasures/measures_info/info_saved_3. Là, copiez l'ensemble des dossiers et collez les ensuite dans le dossier /Memoire/AppsToLaunch en veillez à d'abord supprimer les éléments qui y seraient présents. Vous verrez qu'il y a 6 dossiers, nommés Exp1, Exp2... Exp6. Chacun de ces dossiers est lié à un expérience du 3ème set d'expériences.
Exp1 représente 10nodes qui vont créer un cluster et ajouteront 10données chacun puis attendrons que le cluster ai convergé.
Exp2 représente la même chose sauf que les nodes rejoindront le cluster après avoir ajouté les données plutôt qu'avant.
Exp3 représente une variante d'Exp1 mais avec 100 données plutôt que 10... Etc.

Bien, maintenant que vous avez compris ce que représente le dossier AppsToLaunch, reprennons le script LaunchExp.sh:
Si par exemple, vous utilisez les valeurs suivantes:
"decalage=0, initialNode=1, localNodes=5, iterations=50, experiments=6, duration=60, ipAddress=127.0.0.1"

Le script supprimer les précédentes mesures restantes dans le dossier /Memoire/Mesures.
Le script lancera immédiatement(sans décalage), l'expérience Exp1 et créera donc 5nodes qui formeront un cluster et ajouteront chacun 10 données.
Lorsque tous les nodes auront les mêmes données (donc 50 données dans ce cas), les nodes détecteront progressivement que l'expérience est terminée et les fichiers d'outputs seront créés dans /Memoire/Mesures/Exp1.
Au bout d'une minute après avoir démaré la premières itération, le script tuera les nodes et recréera à nouveau 5 nodes pour lancer la 2ème itération de l'Exp1.
Une fois 50 itérations réalisées (donc ~50min se seront écoulées), le script passera à l'expérience suivante et ainsi de suite.
Ici, dans le cas exposé, le script tournera pendant environ 300min soit 3h avant de se terminer. Pour chaque itération de chaque expérience, chaque node produira un fichier d'outputs.
Dans le cas exposé, il y aura donc 6*50*5=1500 fichiers d'outputs générés. Vu la durée d'exécution de ce script, j'ai généralement lancé cela la nuit afin d'avoir les ficheirs d'ouputs générés pour le lendemain matin, d'autant plus que certains sets d'expériences peuvent comporter plus que 6 expériences et donc durer bien plus longtemps.

Note: Il est possible d'améliorer le script LaunchExp de façon à ne pas devoir modifier pleins de paramètres dedans ni avoir besoin de palcer au préaalble les bons fichiers dans AppsToLaunch.
Pour cela, il faudrait, par exemple, passer en argument le set d'expériences (ou au pire modifier une variable tout en haut) et le script irait de lui-même chercher les fichiers concernés.
Il serait peut-être plus judieux de créer comme ça plusieurs Script, par exemple LaunchSet1.sh, LaunchSet2.sh etc. Chaque script aurait déjà (harcodé) le bon nombre de nodes etc.
Cela fait partie des choses à réaliser quand j'aurai le temps.


