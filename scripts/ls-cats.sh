#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR
cd ..
cats=( $(cat $PWD/scripts/data/categories.yaml | grep -E '\- slug: .*' | awk -F\  '{ print $3 }' | awk '{ print $1 }') )

for cat in "${cats[@]}"
do
   :
  echo "$cat"
done
