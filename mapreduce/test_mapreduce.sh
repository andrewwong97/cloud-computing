#!/bin/bash

# create test input file with 2^10 random messages
echo -n "" > test_input.txt
for i in {1..1024}
do
   printf "%d %s\n" $i $(head -c100 /dev/urandom | LC_ALL=C tr -dc 'a-zA-Z0-9') >> test_input.txt
done

# ensure output is unique
cat test_input.txt | python mapper.py | python reducer.py > test_output.txt

if [[ $(uniq -d test_output.txt) ]]; then
    echo "FAILED - duplicate mod message hash found"
else
    echo "PASSED - only unique mod message hashes"
fi

# clean up
rm test_input.txt
rm test_output.txt