#!/bin/sh
rm -rf .legit

perl legit.pl init
touch a\-b
perl legit.pl add a\-b

touch a b

perl legit.pl add a\-b a b
perl legit.pl commit -m "commit all three files"
perl legit.pl commit -m "nothing to commit"
echo 6 >a
echo 6 >a\-b
perl legit.pl commit -m "nothing to commit"
perl legit.pl add a\-b a b
perl legit.pl commit -m "new commit of a\b and a and b"

rm a a\-b b
