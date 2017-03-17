#!/bin/bash

echo -n "This script install buildscripts into this dir, do you want to processed? [Y/N]: "
read choise
case "$choise" in
  y|Y) git clone https://github.com/Sudokamikaze/Darkspell-scripts.git
  rm Darkspell-scripts/LICENSE
  rm Darkspell-scripts/README.md
  rm Darkspell-scripts/bootstrap.sh
  mv Darkspell-scripts/* ./
  rm -rf Darkspell-scripts
  echo "Done! "
  ;;
  n|N)
  exit 1
  ;;
esac
