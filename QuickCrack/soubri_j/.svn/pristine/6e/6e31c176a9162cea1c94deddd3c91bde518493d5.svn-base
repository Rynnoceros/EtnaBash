#!/bin/bash
INPUT_DIR="./out/www"
OUTFILE="./out/id_ssh"
# Key 2 – Reconstruct SSH key
getKey2()
{
  echo "Searching for key file..."
  # On recherche le fichier de clé dans le répertoire INPUT_DIR
  keyFile=$(file $INPUT_DIR/* | grep "ASCII text, with very long lines" | cut -d: -f1)
  echo "Key file found : $keyFile !"
  
  # On décode le fichier
  decodeKey $keyFile
}
# Methode pour décoder la clé
decodeKey()
{
  echo "Decoding file..."

  # On supprime le contenu du fichier de sortie
  rm $OUTFILE &> /dev/null
 
  # On lit le fichier ligne par ligne
  for line in $(cat $1)
  do
    decodeLine $line
  done
  echo "File decoded!"
}
decodeLine()
{
  # On récupère le paramètres d'entrée
  param=$1
 
  # On calcule la longueur de la clé
  size=${#param}

  # On transforme la ligne en binaire 
  toDecode=$(echo $param | sed "s/\./0/g;s/\*/1/g")
 
  # On boucle sur la ligne pour la décoder
  cpt="0"
  key=""
  while [ $cpt -lt $size ]
  do
    # On récupère l'octet en cours
    octet=${toDecode:cpt:8}
    
    # On décode la ligne en transformant le binaire -> decimal -> octal -> ASCII
    key+=$(printf $(printf "\%o" $((2#${toDecode:cpt:8}))))
    
    # On incrémente le compteur d'un octet
    cpt=$(($cpt + 8))
  done
  echo "$key" >> $OUTFILE
}
getKey2
