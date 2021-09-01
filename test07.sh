#!/bin/sh
rm -rf .legit

perl legit.pl init
echo line 1 >a

perl legit.pl add a
perl legit.pl commit -m '1st commit'

echo line 2 >>a
echo world >b

perl legit.pl add b
perl legit.pl commit -a -m '2nd commit'
perl legit.pl log
echo line 2 >>a
perl legit.pl rm --force b
perl legit.pl status

rm a
