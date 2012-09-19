#!/bin/sh
#cat names/cov.best_least >> tsts.todo
for a in `cat tsts.todo`
do
  echo "------------------------------"
  echo $a
  if [ -e src/$a/$a.out ]
  then
    echo "DONE"
    (cat src/$a/$a.out | grep '^\[ERROR\]')
  else
    ./bin/gentestrun.rb -chunk src/$a
  fi
  #(cat src/$a/$a.out | grep '^\[ERROR\]') && kill -s STOP $$
  #./bin/gentestrun.rb -chunk src/$a
done
