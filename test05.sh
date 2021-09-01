#!/bin/sh
rm -rf .legit

perl legit.pl init
touch a b c
echo 1 >a
echo 2 >b
echo 3 >c
perl legit.pl add a b c

perl legit.pl commit -m "a b c to commit"

perl legit.pl commit -m "commit nothing should be"

echo 2 >>a

perl legit.pl add a b c

perl legit.pl commit -m "should commit a b c"
perl legit.pl rm --force c
cat c
perl legit.pl show :c
perl legit.pl show 0:c
perl legit.pl show 1:c
perl legit.pl log
echo 3 >> a
perl legit.pl add a
perl legit.pl status
rm a
rm b
