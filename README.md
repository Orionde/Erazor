Erazor
======

Permet d'effacer automatiquement tout disque branché dans une baie de disque donee.

Teste avec un DELL R610 et une baie de disque PowerVault MD1220

Necessite les commandes fdisk, megacli et mgasasctl pour fonctionner.

## Prerequis

Ce programme en est encore a sa version d'essai, et de nombreux cas n'ont pas encore ete traites.

C'est pourquoi certaines actions sont a ne SURTOUT PAS FAIRE, sous peine de faire potentiellement planter le programme, voir effacer un disque qui n'aurait pas du l'etre.

Voici donc la liste des choses qu'il faut eviter de faire pour le moment, le comportement du programme n'ayant pas ete defini :

* Ne PAS brancher de disque que vous ne souhaitez pas effacer, et ce sur n'importe quelle baie.

En théorie seuls les disques de la baie selectionneesont effaces. Le programme n'a cependant pas ete teste lors du branchement d'un disque dans une autre baie. Il est donc fortement conseille de ne pas le faire !

* Eviter de debrancher un disque en cours d'effacement, sauf evidemment si vous avez branche un disque que vous ne souaitez pas effacer.

* Ne PAS lancer le programe sans etre certain d'avoir bien repere le disque systeme et la baie a effacer
Avant de pouvoir utiliser le programme, il faut lui indiquer a quel endroit les disques a effacer se situent. Il y a donc quelques reperages a effectuer :

1 ) Disques systeme

Via la commande fdisk -l, cherchez le disque de boot.
```bash
Device     Boot  Start       End   Sectors   Size Id Type
/dev/sda1  *      2048    499711    497664   243M 83 Linux
/dev/sda2       501758 285472767 284971010 135.9G  5 Extended
/dev/sda5       501760 285472767 284971008 135.9G 8e Linux LVM

```
Ici, la partition sur laquelle boote l'OS est /dev/sda1. On va donc indiquer a erazor de ne pas effacer le disque /dev/sda.
Dans une future version, il sera possible de demander a ne pas effacer plusieurs disques. 

2 ) Baie a effacer
Reperez l'identifiant de la baie de disque via la commande megasasctl -vvv. Les identifiants sont de la forme a0, a1, a2...

Soyez certain d'avoir bien repere les deux valeurs ci-dessus ! Si vous vous trompez, vous risqueriez d'effacer votre disque de boot !

## Usage

Pour lancer le programme :
./erazor.sh aX /dev/sdX

(aX etant a remplacer par l'identifiant de votre baie de disque et /dev/sdX par le disque a ne pas effacer)
Nota : Pour le moment, seuls les disques de la forme "/dev/sdX" sont geres. Les autres viendront dans une prochaine version.

Pour remettre a zero les fichiers du programme :
./reinit.sh

## Comment savoir si un disque a finit d'etre efface

Premiere solution : regarder l'output du programme. Si vous ne voyez plus de message du type

```bash
shred: /dev/sdb: pass 1/1 (000000)...278GiB/279GiB 99%
```
c'est que le disque a fini d'etre efface.

Deuxieme solution : regarder les diodes du disque sur la baie.
Tant que la diode de droite est fixe et que celle de gauche clignote rapidement, le disque est en cours d'effacement. Lorsque la diode de gauche s'eteint et que celle de droite est fixe, le disque a fini d'etre efface et est pret a etre ejecte.


## Explications

Le programme erazor.sh tourne en continu via une boucle infinie.

Pour detecter les changements sur les disques, le programme fait des diffs entre la valeur courante d'une commande et la valeur qu'elle avait au precedent tour de boucle. L'output precedent se situe dans les fichiers info_files/xx_old.txt et l'output courant dans info_files:xx_new.txt.

A chaque tour de boucle, elle compare les etats de megasasctl -vvv pour savoir si un nouveau disque a ete branche.

Si elle en detecte un, elle l'efface. 

##
