#!/bin/zsh
# find ./sim.tight > found
cat found | grep '\.m\.' | while read a;
do
  cat $a | more
  echo cat $(echo $a | sed -e 's/\.m\./.i./g')
  echo cat $a
  #env i_LABEL='for' exit="pkill -9 $0" zsh -i
  # use kill -9 % to exit
  #kill -s STOP $$
done
