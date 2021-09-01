#!/bin/sh
rm -r .legit

touch a b c

perl legit.pl init

echo a_flag >a 
perl legit.pl add a
echo b_flag >b
perl legit.pl add b

perl legit.pl show :a
perl legit.pl show :b

perl legit.pl commit -m "a and b added"
perl legit.pl show 0:a
perl legit.pl show 0:b

perl legit.pl rm --force a b
perl legit.pl log

perl legit.pl add c

perl legit.pl status
perl legit.pl commit -m "c added"
perl legit.pl status
rm  c
