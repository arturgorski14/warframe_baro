#!/bin/bash

main_file='main.py'
executable_main='executable_main.sh'

echo $main_file
echo $executable_main

main_last_modification=$(stat -c %y $main_file)
executable_last_modification=$(stat -c %y $executable_main)

echo $main_last_modification
echo $executable_last_modification

if [[ $main_last_modification -nt $executable_last_modification ]]
then
  echo "newer"
  cp $main_file $executable_main
else
  echo "older"
fi

for i in {5..11..2}
do
    echo "ducats per plat value from $i"
    ./$executable_main $i > valuable_items_${i}_100.txt
done
