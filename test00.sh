#!/bin/sh
rm -r .legit
perl legit.pl init
touch a b c
echo 1 >a
echo 1 >b
echo 1 >c

perl legit.pl add a b
perl legit.pl commit -m "add a and b only"
perl legit.pl log

#commit 0 

perl legit.pl add c
echo 2 >>a
perl legit.pl commit -m "add changed a and c"

#at this moment there is 'a' in working dir,
#a is different from index and the lastest commit
#-e $f_index , (compare($f_index, $file) != 0, compare($f_index, $f_master) == 0

perl legit.pl log

#two commit 0 and 1

echo 3 >>b

# b chnaged but not staged for committed same as a
perl legit.pl rm a

perl legit.pl show 0:a
perl legit.pl show 1:a
cat a
#should return error 

perl legit.pl status
rm a
rm b
rm c
