#!/bin/bash

[ -e results.txt ] && rm results.txt
touch test.txt
if [ ! -d "./submissions" ]
then
    mkdir submissions
fi
if [ ! -f "results.txt" ]
then
    touch results.txt
fi
unzip ./submissions.zip -d submissions 
args=$(head -n 1 sampleInput.txt)
for file in ./submissions/*.cpp; do
    echo "Processing submission ${file##*/}"
    sed -i 's/^#include/\n#include <math.h>\n#include/g' $file
    sed -i '0,/^int main()/s//int main(int argc, char** argv)/' $file
    MAIN=$(grep -n "int main" $file | cut -d: -f1)
    CIN=$(tail -n +$MAIN $file | grep -in "cin >> n" | head -1 | cut -d: -f1)
    LAST=$(($MAIN + $CIN))
    sed -i "$MAIN,$LAST s/cin >> n/\/\/cin >> n;\n\tn = atoi(argv[1])/" $file
    output=$(g++ $file 2>&1)
    if [[ $? != 0 ]]; 
    then
        echo "${file##*/} DOESN'T, COMPILE" >> results.txt
    else
        ./a.out $args > test.txt
        diff_lines=`diff test.txt \
					expectedOutput.txt\
					--ignore-space-change --ignore-case  | egrep -c "^<|^>"`
		if [ $diff_lines == 0 ]
	    then
		echo "${file##*/}, CORRECT" >> results.txt
	    else
		    diff_files=$((diff_files+1))
		    echo "${file##*/}, INCORRECT" >> results.txt
	    fi			
    fi
done
rm test.txt
