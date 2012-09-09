#!/usr/bin/zsh
project=$(basename $1) #e.g src/JTailPlus
find coverage/update/$project/ -name coverage.xml | while read i
do
  grep 'srcfile name=' $i;
done | sed -e 's/.*"\(.*\)".*/\1/g' | sort -u
