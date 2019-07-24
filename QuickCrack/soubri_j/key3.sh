#!/bin/bash
OUTFILE="./out/id_ssh"
IP_ADDRESS="163.5.245.214"
LOGIN="halliday_j"
OUTPLANS="./out/plans/"
OUT="./out"
LISTFILE="tmplist.txt"
TMPPWD="tmppwd.txt"
TMPPLANS="tmpplans.txt"
###################################################
### Key 3 – Find and retrieve files using clues ###
###################################################

# Methode pour creer les repertoires de destination
createDirectories()
{
  # On supprime les fichiers temporaires
  rm $LISTFILE $TMPPWD $TMPPLANS &> /dev/null
  
  # On créé le répertoire pour le fichier de mot de passe
  mkdir -p $OUT

  # On créé le répertoire pour les plans
  mkdir -p $OUTPLANS 
}

# Methode pour récupérer les plans
retrievePlans()
{
  # On liste tous les fichiers du serveur
  executeSSHCommand "find . -mtime 8" $LISTFILE
 
  echo "Listing plans"
  cat $LISTFILE | grep "^[[:alpha:]]*.*\-[[:digit:]]\{2\}$" >> $TMPPLANS
}

# Methode pour lancer une commande à distance
executeSSHCommand()
{
  echo "$1/$2"
  ssh -i $OUTFILE $LOGIN@$IP_ADDRESS  $1 >> $2
}

# Methode pour récupérer le fichier des mots de passe
retrievePasswords()
{
  echo "Getting password filePath"
  for file in $(cat $LISTFILE)
  do
    executeSSHCommand "cat $file 2> /dev/null | grep "^[[:alpha:]]*.*:.*$" -o &> /dev/null | if [ \$? -eq 0 ]; then echo $file; fi" $TMPPWD
  done
}
createDirectories
retrievePlans
retrievePasswords
