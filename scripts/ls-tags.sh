#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR
cd ..
tags=( $(cat $PWD/scripts/data/tags.yaml| grep -E '\- slug: .*' | awk -F\  '{ print $3 }' | awk '{ print $1 }') )

for tag in "${tags[@]}"
do
   :
  echo "$tag"
done
