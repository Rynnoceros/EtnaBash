#!/bin/bash
saveFile=".calendar_datas"
tmpFile=".tmp_datas"
param1=$1
param2=$2
nbparam=$#
checkParameters()
{
  if [ $nbparam -gt 0 ]
    then if [ $param1 == "--add" ]
      then addCalendar $param2
    elif [ $param1 == "--delete" ]
      then deleteCalendar $param2
    else
      echo "Wrong arguments"
    fi
  else
    displayCalendar
  fi
}
displayEntete()
{
  printf "| %-18s %s" $1
}
displayLigne()
{
  displayEntete $1
  displayEntete $2
  displayEntete $3
  displayEntete $4
  displayEntete $5
  printf "\n"
}
addCalendar()
{
  echo $1 >> $saveFile
  if [ $? == 0 ]
    then echo "Event added !"
  else
    echo "Error adding event"
  fi
}
deleteCalendar()
{
  grep -o $1 $saveFile > /dev/null
  if [ $? == 0 ]
    then 
      grep -o -s -v $1 $saveFile > $tmpFile
      if [ $? == 0 ] 
        then 
	  echo "Event removed!"
          cat $tmpFile > $saveFile
	  rm $tmpFile
      else
        echo "Problem removing event!"
      fi
  else
    echo "Event not found"
  fi
}
displayCalendar()
{
  echo "TODO"
}
checkParameters $1 $2
