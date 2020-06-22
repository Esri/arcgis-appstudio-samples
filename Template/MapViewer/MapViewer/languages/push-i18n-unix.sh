#!/bin/bash

(set -x; git status)

lines=$(git status | grep "nothing to commit" | wc -l)
if [ "$lines" == 1 ]; then
  echo "Exit - nothing to commit"
  exit 0
fi

lines=$(git status | grep "Changes not staged for commit" | wc -l)
if [ "$lines" == 0 ]; then
  echo "Exit - no changes detected"
  exit 0
fi

(set -x; git diff)
(set -x; git commit -a -m "i18n auto update")
(set -x; git push)
