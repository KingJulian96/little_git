#!/bin/sh
rm -r .legit
perl legit.pl init

touch a b c d
echo 1 >a
echo 2 >b
echo 3 >c
echo 4 >d

perl legit.pl status            #no commit error message

perl legit.pl add a                      #only a added 
perl legit.pl status            #no commit error message

mkdir dirr                      #make a directory
perl legit.pl add dirr          #add a none regular file
rm -r dirr
perl legit.pl add c b d         #only index
perl legit.pl log

perl legit.pl commit -a         #no message
perl legit.pl commit -m
perl legit.pl commit -m "right commit"
perl legit.pl commit -m "nothing commit"

echo new> a
perl legit.pl add a
perl legit.pl commit -m "a new"
perl legit.pl log

echo n> a
echo n> g
perl legit.pl status
rm a b c d g
