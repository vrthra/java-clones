#!/bin/sh
#cat names/cov.best_least >> tsts.todo
for a in `cat tsts.todo`
do
  echo "------------------------------"
  echo -n $a ": "
  #if [ -e src/$a/$a.out ]
  if [ -e src/$a/build.out ]
  then
    if [ -e src/$a/err.test ]
    then
      echo "err:test"
    else
      if [ -e src/$a/err.build ]
      then
        echo "err:build"
        #(cat src/$a/$a.out | grep '^\[ERROR\]' > /dev/null) && echo err || echo passed
        #(cat src/$a/build.out | grep '^\[ERROR\]' > /dev/null) && echo err || echo passed
      else
        if [ -e src/$a/err.mvn ]
        then
          echo "err:mvn $(cat src/$a/err.mvn)"
        #(cat src/$a/$a.out | grep '^\[ERROR\]' > /dev/null) && echo err || echo passed
        else
          (cat src/$a/build.out | grep '^\[INFO\] BUILD SUCCESS' > /dev/null) && echo passed || echo err
        fi
      fi
    fi
  else
    echo notcomplete
  fi
done
