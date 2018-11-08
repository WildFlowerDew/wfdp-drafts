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
  FILES=$DIR/wip/*.p.md
  echo "Processing new draft posts..."
  shopt -s nullglob
  for post in $FILES
  do
    echo "$post"
    filename=$(basename -- "$post")
    cat "$post" | sed -E 's/\!\[s10p\]\(([a-zA-Z0-9]*),([a-zA-Z0-9]*),(.*)\)/{% include spread-ten-pyramid.html deck="\1" card1="\2" cards="\3" index="1" %}/g' | sed -E 's/cards="([a-zA-Z0-9]*),([a-zA-Z0-9]*),([a-zA-Z0-9]*),([a-zA-Z0-9]*),([a-zA-Z0-9]*),([a-zA-Z0-9]*),([a-zA-Z0-9]*),([a-zA-Z0-9]*),([a-zA-Z0-9]*)" card2="\1" card3="\2" card4="\3" card5="\4" card6="\5" card7="\6" card8="\7" card9="\8" card10="\9" /g' | sed -E 's/\!\[s3r\]\((.*),(.*),(.*),(.*)\)/{% include spread-three-row.html deck="\1" card1="\2" card2="\3" card3="\4" index="1" %}/g' | sed -E 's/\!\[card\]\((.*),(.*)\)/{% include card-img.html deck="\1" card="\2" index="1" %}/g' | sed -E 's/\!\[s1\]\((.*),(.*),(.*)\)/{% include card.html deck="\1" card="\2" position="\3" index="1" constrain="true" %}/g' | sed -E 's/\!\[youtube\]\((.*)\)/{% include amp-youtube.html id="\1" %}/g' | sed -E 's/\!\[tweet\]\((.*)\)/{% include amp-tweet-small.html id="\1" %}/g' | sed -E 's/\!\[twl\]\((.*)\)/{% include amp-tweet-large.html id="\1" %}/g' | sed -E 's/\!\[rp\]\((.*)\)/{% include reddit-post.html url="\1" %}/g' | sed -E 's/\!\[pin\]\((.*)\)/{% include amp-pin.html url="\1" %}/g' | sed -E 's/:fa(.)\s(fa\-[a-zA-Z0-9]*):/{% include i.html n="fa\1 \2" %}/g' | sed -E 's/:(fa.\sfa\-.*)\s([a-zA-Z0-9\(\)\,#]*):/{% include icon.html src="\1" color="\2" %}/g' | sed -E 's/\!\[ig\]\((.*)\)/{% include amp-instagram.html shortcode="\1" %}/g' | sed -E 's/\!\[fbv\]\((.*)\)/{% include amp-fb-video-embed.html url="\1" %}/g' | sed -E 's/\!\[fbc\]\((.*)\)/{% include amp-fb-comment-embed.html url="\1" %}/g' | sed -E 's/\!\[bo\]\((.*)\)/{% include amp-beopinion.html id="\1" %}/g' | sed -E 's/\!\[fbp\]\((.*)\)/{% include amp-fb-post-embed.html url="\1" %}/g' | sed -E 's/\!\[(.*)\]\[(.*)\]\[(.*)\]\((.*)\)\((.*)\)/{% include fig.html alt="\1" desc="\2" credit-name="\3" src="\4" credit-src="\5" slug="\1" %} /g' | sed -E 's/\!\[(.*)\]\[(.*)\]\((.*)\)/{% include fig.html alt="\1" desc="\2" src="\3" slug="\1" %} /g' | sed -E 's/\!\[(.*)\]\((.*)\)/{% include fig.html alt="\1" src="\2" slug="\1" %} /g' | cat  > "$DIR/wip/${filename%.*.*}.md"
  done
}

testpost() {
  mkdir -p $DIR/content
  cp $DIR/wip/test.md $DIR/content/test.md
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
setup_git
get_data_files
gen_drafts
preprocess
testpost
commit_website_files
upload_files
echo "Done."
