#!/bin/sh
rm -r .legit
perl legit.pl init
perl legit.pl init

# twice, ruturn error

perl legit.pl add a b

# file does not exist

perl legit.pl add -1-1      #invalid filename

touch a b c
echo line1 >a

echo 20 >c

perl legit.pl add a c
echo new >a

cat a
perl legit.pl show :a
perl legit.pl commit -e "commit wrong command"

perl legit.pl commit -m "commit with right command"

perl legit.pl add b
perl legit.pl commit -m "second commit"

rm a
rm b
rm c
echo 1 >b

perl legit.pl log # two commit only
perl legit.pl status

perl legit.pl rm --ccc  # wrong file name

perl legit.pl rm a #a c do not exists
perl legit.pl rm c

perl legit.pl rm --force c
perl legit.pl rm --force a

perl legit.pl rm --force b
