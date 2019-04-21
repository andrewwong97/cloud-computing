# size of database
N=500

# starting query set size
M=10

shuf -i 0-$N -n $10 > test_input.txt

# ensure output is unique
cat test_input.txt | python db.py | python mapper.py | python reducer.py > test_output_1.txt
cat test_output_1.txt | python db.py | python mapper.py | python reducer.py > test_output_2.txt
cat test_output_2.txt | python db.py | python mapper.py | python reducer.py > test_output_3.txt
cat test_output_3.txt | python db.py | python mapper.py | python reducer.py > test_output_4.txt
cat test_output_4.txt | python db.py | python mapper.py | python reducer.py > test_output.txt


rm test_input.txt
rm test_output_1.txt
rm test_output_2.txt
rm test_output_3.txt
rm test_output_4.txt
rm test_output.txt