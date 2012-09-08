#!/bin/zsh
find sim.tight/ | grep '\.m\.' | while read a;
do
  echo cat $a
  echo cat $(echo $a | sed -e 's/\.m\./.i./g')
  #env i_LABEL='for' exit="pkill -9 $0" zsh -i
  # use kill -9 % to exit
  kill -s STOP $$
done
