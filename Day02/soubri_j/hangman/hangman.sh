#!/bin/bash
ALPHABET="ABCDEFGHIJKLOMNOPQRSTUVWXYZ"
USER_INPUT=""
PROPOSAL=""
DISPLAYE_PROPOSAL=""
FOUND="1"
WORD=""
WORD_NB_LETTERS="0"
FILES=""
NB_SOURCE="0"
IS_EASY="1"
DATABASE_FILE=".database"
TRIES_LEFT="10"
DISPLAYEDWORD=""
checkParameters()
{
  while [ $# -gt 0 ]
  do
    if [ $1 == "--source" ]
      then
        NB_SOURCE=$(echo "v=$NB_SOURCE;v+=1;v" | bc)
        if [ "$2" ]
          then 
            cat $2 &> /dev/null
            if [ $? -gt 0 ]
              then
                echo "$2 cannot be read!"
	        exit 1
            else
              readFile $2
            fi
        else
          echo "Incorrect usage!"
          exit 2
        fi
    elif [ $1 == "--easy" ]
      then
        IS_EASY="0"
    fi
    shift 1
  done

  if [ $NB_SOURCE -le 0 ]
    then
      echo "No source have been provided!"
      exit 3
  elif [ "$FILES" ]
    then
      echo "Incorrect usage!"
      exit 2
  fi
}
readFile()
{
  cat $1 >> $DATABASE_FILE
}
deleteFile()
{
  rm $DATABASE_FILE
}
getRandomWord()
{
  nbLines=$(wc -l $DATABASE_FILE | cut -d. -f1)
  WORD=$(tail -n $(($RANDOM%$nbLines+1)) $DATABASE_FILE | head -n 1)
  WORD="$(tr '[:lower:]' '[:upper:]' <<< $WORD)"
  WORD_NB_LETTERS=${#WORD}
}
askForInput()
{
  calculateDisplayedWord
  echo "Mystery: $DISPLAYEDWORD ($WORD_NB_LETTERS letters, $TRIES_LEFT tries left)"
  echo "Enter a letter or a word:"
  read USER_INPUT
  USER_INPUT="$(tr '[:lower:]' '[:upper:]' <<< $USER_INPUT)"
  if [ ${#USER_INPUT} -eq 1 ]
    then
      letterInput
      removeProposal
      calculateDisplayedWord
  else
    wordInput
  fi

  if [ $DISPLAYEDWORD == $WORD ]
    then
      FOUND="0"
      echo "You have discovered the mystery: $WORD! You win!!!"
  elif [ $FOUND != 0 ]
    then
      echo "Previous letters propositions were:$DISPLAYED_PROPOSAL"
  fi
}
calculateDisplayedWord()
{
  DISPLAYEDWORD=$(echo $WORD | tr "[$ALPHABET]" "_")
}
removeProposal()
{
  ALPHABET="$(echo $ALPHABET | tr -d $PROPOSAL)"
}
letterInput()
{
  echo $WORD | grep -s -o $USER_INPUT &> /dev/null
  if [ $? -eq 0 ]
    then
      echo "$USER_INPUT found!"
  else
    echo "$USER_INPUT not found!"
    TRIES_LEFT=$(($TRIES_LEFT - 1))
  fi
  PROPOSAL+=$USER_INPUT
  addDisplayedProposal $USER_INPUT
}
addDisplayedProposal()
{
  echo $DISPLAYED_PROPOSAL | grep -o $1 &> /dev/null
  if [ $? -gt 0 ]
    then
      DISPLAYED_PROPOSAL+=" $1"
  fi
}
wordInput()
{
  if [ "$USER_INPUT" != "$WORD" ]
    then 
      echo "$USER_INPUT is not the mystery!"
      TRIES_LEFT=$(($TRIES_LEFT - 2))
      echo $TRIES_LEFT
  else
    FOUND="0"
    echo "$WORD was the mystery! You win!!!"
  fi
}
modeEasy()
{
  PROPOSAL+=${WORD:0:1}
  addDisplayedProposal ${WORD:0:1}
  PROPOSAL+=${WORD:$((${WORD} -1)):1}
  addDisplayedProposal ${WORD:$((${WORD} -1)):1}
  removeProposal
  calculateDisplayedWord
}
startGame()
{
  if [ $IS_EASY -eq 0 ]
    then
      modeEasy
  fi
  while [ $TRIES_LEFT -gt 0 ] && [ $FOUND -eq 1 ]
  do
    askForInput
  done
  if [ $TRIES_LEFT -le 0 ]
    then
      echo "No more tries! LOOSER!!!"
      echo "Mystery was: $WORD"
  fi
}
checkParameters $@
getRandomWord
startGame
deleteFile
