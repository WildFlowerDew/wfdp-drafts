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
  mkdir -p $DIR/wip
  FILES=$DIR/wip/*.txt
  echo "Processing new draft posts..."
  shopt -s nullglob
  for post in $FILES
  do
    echo "$post"
    $DIR/scripts/txt-to-md.sh $post
  done
}

preprocess() {
  mkdir -p $DIR/wip
  FILES=$DIR/*.p.md
  echo "Processing new draft posts..."
  shopt -s nullglob
  for post in $FILES
  do
    echo "$post"
    cat "$post" | sed -E 's/\!\[rp\]\((.*)\)/{% include reddit-post.html url="\1" %}/g' | sed -E 's/\!\[pin\]\((.*)\)/{% include amp-pin.html url="\1" %}/g' | sed -E 's/:(fa.\sfa\-.*)\s(.*):/{% include icon.html src="\1" color="\2" %}/g' |sed -E 's/:(fa.\sfa\-.*):/{% include i.html n="\1" %}/g' | sed -E 's/\!\[ig\]\((.*)\)/{% include amp-instagram.html shortcode="\1" %}/g' | sed -E 's/\!\[fbv\]\((.*)\)/{% include amp-fb-video-embed.html url="\1" %}/g' | sed -E 's/\!\[fbc\]\((.*)\)/{% include amp-fb-comment-embed.html url="\1" %}/g' | sed -E 's/\!\[bo\]\((.*)\)/{% include amp-beopinion.html id="\1" %}/g' | sed -E 's/\!\[fbp\]\((.*)\)/{% include amp-fb-post-embed.html url="\1" %}/g' | sed -E 's/\!\[(.*)\]\[(.*)\]\[(.*)\]\((.*)\)\((.*)\)/{% include fig.html alt="\1" desc="\2" credit-name="\3" src="\4" credit-src="\5" slug="\1" %} /g' | sed -E 's/\!\[(.*)\]\[(.*)\]\((.*)\)/{% include fig.html alt="\1" desc="\2" src="\3" slug="\1" %} /g' | sed -E 's/\!\[(.*)\]\((.*)\)/{% include fig.html alt="\1" src="\2" slug="\1" %} /g' | cat
  done
}

commit_website_files() {
  git checkout master
  git add content img wip
  git commit --message "Travis build: $TRAVIS_BUILD_NUMBER"
}

upload_files() {
  git remote add origin-build-master "https://${GT}@github.com/$GU/wfdp-drafts" > /dev/null 2>&1
  git push --quiet --set-upstream origin-build-master master
}

echo "Building Website Drafts"
#setup_git
#get_data_files
#gen_drafts
#commit_website_files
#upload_files
preprocess
echo "Done."
