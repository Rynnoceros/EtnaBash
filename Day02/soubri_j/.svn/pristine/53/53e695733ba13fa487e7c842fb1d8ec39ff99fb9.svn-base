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
NB_N="0"
IS_EASY="1"
DATABASE_FILE=".database"
STORE_FILE=".hangmanstate"
TRIES_LEFT="10"
DISPLAYEDWORD=""
checkParameters()
{
  params=$#
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
    elif [ $1 == "-n" ] || [ $1 == "--new" ]
      then
        NB_N=$(($NB_N + 1))
    fi
    shift 1
  done

  var=$(less <&0 2> /dev/null)
  if [ $params -eq 0 ]
    then
      loadState
      if [ "$var" ]
        then
          play $var
          gameOver
          if [ $FOUND -gt 0 ] && [ $TRIES_LEFT -gt 0 ]
            then
              writeState
          fi
      fi
  else
    if [ $NB_SOURCE -le 0 ]
      then
        echo "No source have been provided!"
        exit 3
    elif [ "$FILES" ]
      then
        echo "Incorrect usage!"
        exit 2
    elif [ $NB_N -gt 0 ]
      then
        startGame
    fi
  fi
}
play()
{ 
  param=$1
  param="$(tr '[:lower:]' '[:upper:]' <<< $param)"
  if [ ${#param} -eq 1 ]
    then
      letterInput $param
      removeProposal
      calculateDisplayedWord
  else
    wordInput $param
  fi

  if [ $DISPLAYEDWORD == $WORD ]
    then
      FOUND="0" 
      echo "You have discovered the mystery: $WORD! You win!!!"
  fi
}
gameOver()
{ 
  if [ $TRIES_LEFT -le 0 ]
    then
      echo "No more tries! LOOSER!!!"
      echo "Mystery was: $WORD"
  fi
  if [ $FOUND -eq 0 ] || [ $TRIES_LEFT -le 0 ]
    then
      deleteFiles
  fi
}
readFile()
{
  cat $1 >> $DATABASE_FILE
}
deleteFiles()
{
  rm -f $DATABASE_FILE 2> /dev/null
  rm -R $STORE_FILE
}
getRandomWord()
{
  nbLines=$(wc -l $DATABASE_FILE | cut -d. -f1)
  WORD=$(tail -n $(($RANDOM%$nbLines+1)) $DATABASE_FILE | head -n 1)
  WORD="$(tr '[:lower:]' '[:upper:]' <<< $WORD)"
  WORD_NB_LETTERS=${#WORD}
}
displayMysteryLine()
{
  echo "Mystery: $DISPLAYEDWORD ($WORD_NB_LETTERS letters, $TRIES_LEFT tries left)"
}
firstDisplay()
{
  calculateDisplayedWord
  displayMysteryLine
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
  PROPOSAL+=$1
  addDisplayedProposal $1
  removeProposal
  calculateDisplayedWord
  
  echo $WORD | grep -s -o $1 &> /dev/null
  if [ $? -eq 0 ]
    then
      echo "$1 found!"
      displayMysteryLine
  else
    TRIES_LEFT=$(($TRIES_LEFT - 1))
    echo "$1 not found! $TRIES_LEFT tries left!"
  fi
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
  if [ $1 != $WORD ]
    then 
      TRIES_LEFT=$(($TRIES_LEFT - 2))
      echo "$1 is not the mystery! $TRIES_LEFT tries left!"
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
  echo "New game!"
  getRandomWord
  if [ $IS_EASY -eq 0 ]
    then
      modeEasy
  fi
  firstDisplay
  writeState
}
writeState()
{
  echo "mystery=$WORD" > $STORE_FILE
  echo "proposal=$PROPOSAL" >> $STORE_FILE
  echo "displayedProposal=$DISPLAYED_PROPOSAL" >> $STORE_FILE
  echo "alphabet=$ALPHABET" >> $STORE_FILE
  echo "wordNbLetters=$WORD_NB_LETTERS" >> $STORE_FILE
  echo "triesLeft=$TRIES_LEFT" >> $STORE_FILE
  echo "displayedWord=$DISPLAYEDWORD" >> $STORE_FILE
}
loadState()
{
  cat $STORE_FILE &> /dev/null
  if [ $? -eq 0 ]
    then
      WORD=$(cat $STORE_FILE | grep "mystery" | cut -d= -f2)
      PROPOSAL=$(cat $STORE_FILE | grep "proposal" | cut -d= -f2)
      DISPLAYED_PROPOSAL=$(cat $STORE_FILE | grep "displayedProposal" | cut -d= -f2)
      ALPHABET=$(cat $STORE_FILE | grep "alphabet" | cut -d= -f2)
      WORD_NB_LETTERS=$(cat $STORE_FILE | grep "wordNbLetters" | cut -d= -f2)
      TRIES_LEFT=$(cat $STORE_FILE | grep "triesLeft" | cut -d= -f2)
      DISPLAYEDWORD=$(cat $STORE_FILE | grep "displayedWord" | cut -d= -f2)
      echo "Previous letters propositions were:$DISPLAYED_PROPOSAL"
      displayMysteryLine
  else
    echo "No game in progress and no source provided! Exiting!"
    exit 4
  fi
}
checkParameters $@
