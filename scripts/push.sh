#!/bin/sh


setup_git() {
  git clone "https://${GH_TOKEN}@github.com/$gu/wildflowerdew.github.io.git" site
  cd site
  git config --global user.email "33005735+WildFlowerDew@users.noreply.github.com"
  git config --global user.name "Wild Flowerdew"
  cd ..
}

commit_website_files() {
  mv content/test.md site/home/test.md
  mv content/*.md site/_posts
  cp -r img/posts/* site/img/posts/
  cd site
  git checkout master
  git add img _drafts _posts home
  git commit --message "Wild Flowerdew: Pushing new posts."
  cd ..
  rm -fr img/posts/*
}

upload_website_files() {
  cd site
  git remote add origin-build-master https://${GH_TOKEN}@github.com/WildFlowerDew/wildflowerdew.github.io.git > /dev/null 2>&1
  git push --quiet --set-upstream origin-build-master master
  cd ..
}

commit_local_files() {
  git add img content
  git commit --message "Wild Flowerdew: New draft post pushed, removing local files."
}

upload_local_files() {
  git push --quiet
}

setup_git
commit_website_files
upload_website_files
commit_local_files
upload_local_files
