#!/bin/bash
ETNA_LAT="48.8138765"
ETNA_LON="2.392521"
PI="3.14159265358"
URL_SUNRISE=$(echo "https://api.sunrise-sunset.org/json?lat=$ETNA_LAT&lng=$ETNA_LON")
if [ "$#" -gt 0 ]
  then ISS=$(curl -s $1)
else
  ISS=$(curl -s "http://api.open-notify.org/iss-now.json")
fi
SUNRISE=$(curl -s $URL_SUNRISE)
ISS_LAT=$(echo $ISS | grep -o '"latitude": ".*' | cut -d, -f1 | cut -d: -f2 | cut -d\" -f2)
ISS_LON=$(echo $ISS | grep -o '"longitude": ".*' | cut -d, -f1 | cut -d: -f2 | cut -d\" -f2)

ER="6371"
dlat=$(echo "var=$ISS_LAT;var-=$ETNA_LAT;var*=$PI;var/=180;var" | bc -l)
dlon=$(echo "var2=$ISS_LON;var2-=$ETNA_LON;var2*=$PI;var2/=180;var2" | bc -l)
l1=$(echo "var3=$ETNA_LAT;var3*=$PI;var3/=180;var3" | bc -l)
l2=$(echo "var4=$ISS_LAT;var4*=$PI;var4/=180;var4" | bc -l)
a2=$(echo "v2=s($dlon/2);v2*=s($dlon/2);v2*=c($l1);v2*=c($l2);v2" | bc -l)
a=$(echo "v=s($dlat/2);v*=s($dlat/2);v+=$a2;v" | bc -l)
s1=$(echo "v3=sqrt($a);v3" | bc -l)
s2=$(echo "v4=sqrt(1 - $a);v4" | bc -l)
s1=$(echo "v5=$s1;v5*=180;v5/=$PI;v5" | bc -l)
s2=$(echo "v6=$s2;v6*=180;v6/=$PI;v6" | bc -l)
atan=$(echo $s1 $s2 | awk '{print atan2($1,$2)}' | tr , .)
result=$(echo "v5=2;v5*=$atan;v5*=$ER;v5" | bc -l)
echo "Today we are $(date '+%A %B %d, %Y.')"
echo "Sunrise is expected at $(echo $SUNRISE | cut -c 24-33) and sunset at $(echo $SUNRISE | cut -c 46-55)"
echo "The ISS is currently located at $(echo $ISS_LAT), $(echo $ISS_LON): ${result%.*} km from us!"
