#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR
cd ..
root=$PWD/content
name=$(basename "$1" .txt)
year="$( echo $name | cut -c7-10 )"
month="$( echo $name | cut -c1-2 )"
day="$( echo $name | cut -c4-5 )"
title="$( echo $name | cut -c1-11 --complement )"

filename="$year-$month-$day-$title.md"
file=$root/$filename

echo "File date $day/$month/$year"

TAGS="$( $DIR/ls-tags.sh | tr '\n' ',' )"
CATS="$( $DIR/ls-cats.sh | tr '\n' ',' )"
PHOTOS="$PWD/img/posts/$year/$month/$day"

echo "Making photos directory"
mkdir -p "$PHOTOS"
cd $root
shopt -s extglob
echo "Copy into photos directory"
mv -f !(*.txt|*.TXT|*.md|*.MD) "$PHOTOS"
cd ..
ls -l $PHOTOS
echo $PWD

echo "Create markdown file"
echo "---" > $file
cat $DIR/data/standard-frontmatter.md >> $file
echo "tags            : [$TAGS]" >> $file
echo "categories      : [$CATS]" >> $file
echo "---" >> $file
cat $1 >> $file
echo "Images:"
echo "Images:" >> $file
ls -l $PHOTOS
for f in "$PHOTOS/*"
do
  echo "Adding image $f..."
  img="$( basename $f )"
  imgfile="$PWD/img/posts/$year/$month/$day/$img"
  tagstart='{% include fig.html src="'
  tagend='" alt="" desc="" credit-src="" credit-name="" %}'
  str="$tagstart$imgfile$tagend"
  echo "$str" >> $file
done
echo "" >> $file
cat $DIR/data/standard-postmatter.md >> $file
rm $1
