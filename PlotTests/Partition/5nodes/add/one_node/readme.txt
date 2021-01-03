This shows:

Si un node est sous partition (ou est seul) puis join un cluster, les modifications qu'il a fait localement sont bien envoyées au cluster même si ces modifications étaient faites sous partition.
Cela se fait à la même vitesse que si le node faisait l'update au moment où il resolve la partition.
Autrement dit, cela montre que si un node est temporairement sous partition puis resolve, le cluster convergera en prenant en compte les mises à jour qui ont été faites par le node qui était sous partition et ne sera pas spécialement impacté (ces modifications de la part du node convergeront sur le cluster à la même vitesse que pour un autre node, dès que la partition est résolue).

C'est un premier élément positif mais ce n'et pas encore assez.

Il reste à regarder l'impact pour le node en question qui était sous partition, est-ce qu'il catch up rapidement et obtient la valeur récente du cluster?
C'est ce que je montre dnas l'autre dossier.
