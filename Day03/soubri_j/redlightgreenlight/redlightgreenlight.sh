#!/bin/bash
DATABASE=".redlightgreenlightdb"
TMPFILE=".tmp"
DISPLAY=".dsp"
DIGEST="sha1"
NEW="1"
CHECK="1"
startProgram()
{
  if [ $# -le 0 ]
    then
      echo "No parameters found, exiting!"
  else
    readParameters $@
    executeProgram
  fi
}
readParameters()
{
  while [ $# -gt 0 ]
  do
    if [ $1 == "--new" ]
      then
        NEW="0"
    elif [ $1 == "--digest" ]
      then
        checkDigest $2
    elif [ $1 == "--check" ]
      then
        CHECK="0"
    fi
    shift 1
  done
}
checkDigest()
{
  if [ $# -le 0 ]
    then
      if [ "$CHECK" == "1" ]
        then 
          echo "No digest algorithm specified, sha1 will be used!"
      fi
  else
    if [ $1 != "md5" ] && [ $1 != "sha1" ] && [ $1 != "sha256" ] && [ $1 != "sha384" ] && [ $1 != "sha512" ]
      then
        echo "$1 is not recognized algorithm. Please use one of the following (md5, sha1, sha256, sha384, sha512)! Exiting!"
        exit 1
    else
      DIGEST=$1
    fi
  fi
}
executeProgram()
{
  if [ $NEW -eq 0 ] && [ $CHECK -eq 0 ]
    then
      echo "You cannot specify --new and --check options at the same time! Exiting!"
      exit 2
  else
    if [ $NEW -eq 0 ] 
      then
        createDatabase
    elif [ $CHECK -eq 0 ] 
      then
        checkFilesAndDirectories
    fi
  fi
}
createDatabase()
{
  cat $DATABASE &> /dev/null
  if [ $? -eq 0 ]
    then
      echo "An existing database have been found, exiting!"
      exit 3
  else
    buildDatabase
  fi
}
buildDatabase()
{
  printf "Please wait building database using $DIGEST..."
  echo "digest=$DIGEST" >> $DATABASE
  buildFile $DATABASE $TMPFILE
  echo " done!"
}
buildFile()
{
  for line in $(find . | grep "\.$" -v | grep $DISPLAY -v | grep "\.\/$1" -v | grep "$2" -v | grep "$0" -v)
  do
    if [ -d $line ]
      then 
        echo "$line=$(ls $line | wc -w | tr -d '[ ]')=d" >> $1
    else
      echo "$line=$(openssl dgst -$DIGEST $line | cut -d= -f2 | tr -d '[ ]')=f" >> $1
    fi
  done
}
checkFilesAndDirectories()
{
  getDigest
  buildFile $TMPFILE $DATABASE
  checkDatabaseFile
  checkTmpFile
  displayResult
  clearFiles
}
displayResult()
{
  cat $DISPLAY 2>> /dev/null | sort
}
clearFiles()
{
  rm $TMPFILE &> /dev/null
  rm $DISPLAY &> /dev/null
}
getDigest()
{
  DIGEST=$(cat $DATABASE | grep "digest=" | cut -d= -f2)
}
checkDatabaseFile()
{
  for line in $(cat $DATABASE)
  do
    element="$(echo $line | cut -d= -f1)"
    if [ "$element" != "digest" ]
      then
        otherLine=$(cat $TMPFILE | grep "$element=")
        if [ $? -gt 0 ]
          then
            if [ "$(echo $line | cut -d= -f3)" == "d" ]
              then
                echo "${element:2} [DD]" >> $DISPLAY
            else
              echo "${element:2} [DF]" >> $DISPLAY
            fi
        elif [ -f $element ] && [ "$(echo $line | cut -d= -f2)" != "$(echo $otherLine | cut -d= -f2)" ]
          then
            echo "${element:2} [MF]" >> $DISPLAY
        fi
    fi 
  done
}
checkTmpFile()
{
  for line in $(cat $TMPFILE)
  do
    element="$(echo $line | cut -d= -f1)"
    otherLine=$(cat $DATABASE | grep "$element=")
    if [ $? -gt 0 ]
      then
        if [ -d $element ]
          then
            echo "${element:2} [ND]" >> $DISPLAY
        else
          echo "${element:2} [NF]" >> $DISPLAY
        fi
    fi
  done
}
startProgram $@
