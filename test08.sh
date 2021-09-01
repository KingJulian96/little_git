#!/bin/sh
rm -rf .legit

perl legit.pl init
touch a b c
echo a > b
echo c > a
echo b > c

mkdir A

perl legit.pl add A

perl legit.pl add a b c
perl legit.pl commit -a "commit with -a"

perl legit.pl show :a
echo aa >>a
perl legit.pl status
rm -rf A
