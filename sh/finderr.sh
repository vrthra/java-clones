#!/bin/sh
#cat names/cov.best_least >> tsts.todo
for a in `cat tsts.todo`
do
  echo "------------------------------"
  echo $a
  #if [ -e src/$a/$a.out ]
  if [ -e src/$a/build.out ]
  then
    #(cat src/$a/$a.out | grep '^\[ERROR\]' > /dev/null) && echo err || echo passed
    (cat src/$a/build.out | grep '^\[ERROR\]' > /dev/null) && echo err || echo passed
  else
    echo notcomplete
  fi
done
