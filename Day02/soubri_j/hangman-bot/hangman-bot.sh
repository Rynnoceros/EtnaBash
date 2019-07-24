#!/bin/bash
GAME_PATH=""
RESPONSE_FILE="response.txt"
DATABASE=".database"
YOU_WIN=""
YOU_LOOSE=""
WORD=""
GREP_WORD=""
NB_WORD_FOUND="0"
PROPOSE_WORD=""
ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
LETTER=""
checkParameters()
{
    if [ $1 == "--game" ]
    then
        GAME_PATH=$2
        shift 2
        rungame $@
    fi
}
rungame()
{
    . ./$GAME_PATH --new $@ > $RESPONSE_FILE
    sleep 1
    while [ "$YOU_WIN" == "" ] && [ "$YOU_LOOSE" == "" ]
    do
        playgame
    done
    cat $RESPONSE_FILE
     
}
playgame()
{
    cat $RESPONSE_FILE
    WORD=$(cat $RESPONSE_FILE | tail -n 2 | grep "Mystery" | cut -d" " -f2)
    findWord
    if [ $NB_WORD_FOUND -eq 1 ]
    then
        proposeWord && echo $PROPOSE_WORD  | . ./$GAME_PATH > $RESPONSE_FILE
    else
        selectLetterFromWord && echo $LETTER | . ./$GAME_PATH > $RESPONSE_FILE
    fi
    sleep 2
    YOU_WIN=$(cat $RESPONSE_FILE | grep "You win" -o)
    YOU_LOOSE=$(cat $RESPONSE_FILE | grep "LOOSER" -o)
}
#proposeLetter()
# {
    #NB_LETTRE=${#ALPHABET}
    #LETTER=${ALPHABET:$RANDOM%${#ALPHABET}:1}
    #ALPHABET=$(echo $ALPHABET | tr -d "$LETTER")
#}
findWord()
{
    GREP_WORD=$(echo $WORD | sed "s/_/\./g" | tr [:lower:] [:upper:])
    NB_WORD_FOUND=$(cat $DATABASE | tr [:lower:] [:upper:] | grep "^$GREP_WORD$" | wc -w)
}
proposeWord()
{
    PROPOSE_WORD=$(cat $DATABASE | tr [:lower:] [:upper:] | grep "^$GREP_WORD$")
}
selectLetterFromWord()
{
    POS_DOT=$(findFirstDot $GREP_WORD)
    ELIGIBLE_WORDS=$(cat $DATABASE | tr [:lower:] [:upper:] | grep "^$GREP_WORD$")
    NB_WORDS="0"
    CHOOSED_LETTER=""
    for SELECTED_WORD in $ELIGIBLE_WORDS
    do
        NEW_GREP=$(echo $GREP_WORD | sed "1,//s/\./${SELECTED_WORD:$POS_DOT:1}/")
        COUNT=$(echo $ELIGIBLE_WORDS | grep "^$NEW_GREP$" | wc -w)
        if [ $COUNT > $NB_WORDS ]
        then
            PROP_LETTER=${SELECTED_WORD:POS_DOT:1}
            if [ "$(echo $ALPHABET | grep $PROP_LETTER -o)" != "" ]
            then
                CHOOSED_LETTER=$PROP_LETTER
                NB_WORDS=$COUNT
            fi
        fi
    done
    LETTER=$CHOOSED_LETTER
    ALPHABET=$(echo $ALPHABET | tr -d "$LETTER")
}
findFirstDot()
{
    param=$1
    cpt="0"
    while [ "${param:$cpt:1}" != "." ]
    do
        cpt=$(($cpt + 1))
    done
    echo $cpt
}
checkParameters $@