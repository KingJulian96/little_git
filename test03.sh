#!/bin/sh
rm -rf .legit
#opreation witht out the init
perl legit.pl add
perl legit.pl show :a
perl legit.pl log

perl legit.pl init

touch a a_b b
#_ should be allowed

perl legit.pl add a b

perl legit.pl commit -m "commit a and b only"
echo 1> a_b
perl legit.pl add a_b
perl legit.pl commit -m "commit another"

perl legit.pl rm --cached a_b
perl legit.pl commit -m "romve the a_b"

perl legit.pl rm a_b
# should not have a_b anymore

echo 2> a_b
perl legit.pl add a_b
perl legit.pl commit -m "add the a_b"

echo 1> a_b

perl legit.pl status
rm a a_b b
