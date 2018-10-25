#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
REPO="wildflowerdew.github.io"
GU="$gu"
GT="${GH_TOKEN}"

setup_git() {
  git config --global user.email "33005735+WildFlowerDew@users.noreply.github.com"
  git config --global user.name "Wild Flowerdew"
}

get_data_files() {
  for f in "categories.yaml" "tags.yaml"
  do
    echo "Fetching $f..."
    curl -H "Authorization: token $GT" -H "Accept: application/vnd.github.v3.raw" -O -L "https://api.github.com/repos/$GU/$REPO/contents/_data/$f"
  done
  for f in "standard-frontmatter.md" "standard-postmatter.md"
  do
    echo "Fetching $f..."
    curl -H "Authorization: token $GT" -H "Accept: application/vnd.github.v3.raw" -O -L "https://api.github.com/repos/$GU/$REPO/contents/scripts/data/$f"
  done
  mv -f *.yaml $DIR/scripts/data
  mv -f *.md $DIR/scripts/data
}

gen_drafts() {
  FILES=$DIR/content/*.txt
  echo "Processing new draft posts..."
  shopt -s nullglob
  for post in $FILES
  do
    echo "$post"
    $DIR/scripts/txt-to-md.sh $post
  done
}

commit_website_files() {
  git checkout master
  git add content img
  git commit --message "Travis build: $TRAVIS_BUILD_NUMBER"
}

upload_files() {
  git remote add origin-build-master "https://${GT}@github.com/$GU/wfdp-drafts" > /dev/null 2>&1
  git push --quiet --set-upstream origin-build-master master
}

echo "Building Website Drafts"
setup_git
get_data_files
gen_drafts
commit_website_files
upload_files
echo "Done."
