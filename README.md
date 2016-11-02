Erazor
======

Permet d'effacer automatiquement tout disque branché dans une baie de disque donnée.

Teste avec un DELL R610 et une baie de disque PowerVault MD1220

Nécessite les commandes fdisk, megacli et mgasasctl pour fonctionner.

## Prérequis

Ce programme en est encore a sa version d'essai, et de nombreux cas n'ont pas encore été traites.

C'est pourquoi certaines actions sont a ne **surtout pas faire**, sous peine de faire potentiellement planter le programme, voir effacer un disque qui n'aurait pas du l’être.

* Ne **pas brancher de disque que vous ne souhaitez pas effacer** sur la baie que vous avez signalée comme à effacer.

Le programme efface tout disque branché sur la baie signalée. Si vous souhaitez brancher un disque sans l'effacer, branchez-le sur une autre baie.

* Éviter de débrancher un disque en cours d'effacement, sauf si vous vous êtes trompé en branchant un disque que vous ne souhaitez pas effacer

* Ne pas lancer le programme sans être certain d'avoir bien repéré le disque système et la baie a effacer
Avant de pouvoir utiliser le programme, il faut lui indiquer a quel endroit les disques a effacer se situent. Il y a donc quelques repérages a effectuer :

1 ) Disque système

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
Repérez l'identifiant de la baie de disque via la commande megasasctl -vvv. Les identifiants sont de la forme a0, a1, a2...

Soyez certain d'avoir bien repéré les deux valeurs ci-dessus ! Si vous vous trompez, vous risqueriez d'effacer votre disque de boot !

## Usage
Avant de lancer le programme une première fois, lancez le script reinit_file_status.sh **avant de brancher les disques à effacer**. Il permet d'initialiser les fichiers du programme.

Pour lancer le programme :
```bash
./erazor.sh X /dev/sdY
```

(X etant a remplacer par le chiffre de l'identifiant de votre baie de disque et /dev/sdY par le disque à ne pas effacer)
Nota : Pour le moment, seuls les disques de la forme "/dev/sdX" sont gérés. Les autres viendront dans une prochaine version.

Pour remettre a zéro les fichiers du programme :
```bash
./reinit_file_status.sh
```

## Comment savoir si un disque a finit d’être efface

Première solution : regarder l'output du programme. Si vous ne voyez plus de message du type

```bash
shred: /dev/sdb: pass 1/1 (000000)...278GiB/279GiB 99%
```
c'est que le disque a fini d’être efface.

Deuxième solution : regarder les diodes du disque sur la baie.
Tant que la diode de droite est fixe et que celle de gauche clignote rapidement, le disque est en cours d'effacement.

Lorsque la diode de gauche s’éteint et que celle de droite est fixe, le disque a fini d’être efface et est prêt a être éjecté.

## Surveiller l'état des disques

Si vous remarquez qu'un disque que vous venez de brancher n'a pas l'air d'être en train de s'effacer (la diode de droite reste allumée et elle de gauche ne clignote pas), vérifiez le contenu du fichier logs.log. Les erreurs des disques y sont indiquée !

Si aucun problème n'a été rencontré pour un disque, vous devriez y voir :
```bash
Adapter 0: Created VD 0

Adapter 0: Configured the Adapter!!

Exit Code: 0x00
```

Si vous avez autre chose, il est fort probable que le programme n'ait pas réussi à monter le disque. Branchez le disque sur une autre baie ou sur un autre serveur et réinitialisez sa configuration :
```bash
megacli -CfgClr -a0 #a0 étant à remplacer par l'identifiant de la baie

et/ou

megacli -CfgForeign -Clear -a0

Tentez ensuite de monter le disque via
megacli -CfgLdAdd -r0 [9:1] -a0

# 9 est un autre identifiant. Pour le récupérer :
megacli -PDList -a$ID_RAID | grep "Enclosure Device ID:" | awk '{print $4}' | sort | uniq

# 1 est l'identifiant du disque, il correspond au numéro du disque (regardez sur la baie ou faites un megasasctl -vvv)

```


## Explications

Le programme erazor.sh tourne en continu via une boucle infinie.

Pour détecter les changements sur les disques, le programme fait des diffs entre la valeur courante d'une commande et la valeur qu'elle avait au précédent tour de boucle. L'output précédent se situe dans les fichiers info_files/xx_old.txt et l'output courant dans info_files/xx_new.txt.

A chaque tour de boucle, elle compare les états de megasasctl -vvv pour savoir si un nouveau disque a été branché.

Si elle en détecte un, elle l'efface.


