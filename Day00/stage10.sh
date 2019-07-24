#!/bin/bash
if [ $# != "2" ]
  then exit 1
fi
if [ "$1" != "[:digit:]" || "$2" != "[:digit:]" ]
  then exit 2
fi
exit 0
