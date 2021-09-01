#!/bin/sh
rm -rf .legit
perl legit.pl log
perl legit.pl show :a
perl legit.pl status
perl legit.pl init

echo 4 >a
echo 3 >b
echo 2 >c
echo 1 >d

perl legit.pl add a b
perl legit.pl commit -m "a and b have been added"
perl legit.pl add c d
perl legit.pl log
perl legit.pl show :a
perl legit.pl show :b
perl legit.pl show 0:a
perl legit.pl show 0:b
perl legit.pl commit -m "c and d have been added"

rm a b c d
