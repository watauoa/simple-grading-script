# This program aims to prog1's grading more quickly. The uniqueness of this program is the partial score interaction and the score outputting.
# 
# Usage:
# 1 Change the below variables appropriately.
# You may have to customize any other part to fit the exercise's problem. 
# About variables, read the explanations below.
# 
# 2 After you run this program, you interact about partial scores.
# Whenever a student's program is executed, you will see a message about the partial score. If you think this program or output deserves to earn the partial score, you can instruct the program to add the partial score by pressing the yes_char key (mention below). If you think this program doesn't deserve it, press any other keys than the yes_char key.
# 
# 3 Input the scores to the spreadsheet by viewing the score file.
# The score file is named like score_ex3_prog01_C3.txt and is in the directory created like ex3_prog01_C3.
# You can input scores more quickly than inputting manually.
# At first, you have to show only scores with this command:
# cat score_ex3_prog01_C3.txt | cut -d, -f2
# Next, you can paste scores in once by copying the whole output of the above command and pasting it with ctrl-v after selecting the most above cell.

# The input string. Inputting enter key should be expressed as \n. Additionally, inputting ctrl-d doesn't have to express in this string.
# If an input is from a file specified by a file name, this string should be the one-line content string that was replaced from newline to \n.
# If an input is command line arguments, you have to modify the part "running the program".
stdinstr="C1 1251001 Yamada 100\nC2 1251022 Watanabe 65\nC4 1251033 Saito 80\nC3 1251001 Suzuki 70\n"

# Those variables are about partial part interaction. 
# The msg is the sentence that will be displayed in the interaction. Those sentences are up to you, so it's OK to write like msg=("1" "2" "3") if you know what the numbers mean.
# The meaning of part_score is obvious. The order of the numbers corresponds to the order of msg.
file_exist_score=20
compilable_score=20
msg=("Key to record?" "header file fixes?" "In main(), key input to insert and after process?")
part_score=(30 10 20)

# In the partial score interaction, the key of this character means the program satisfies the condition. Any other character means decline.
# The default value is "m" because it's easy to press repeatedly.
yes_char="m"

# Exercise number
# Though it's OK to write like ex12, ex06, and so on.
ex_num=9

# Program name.
# Example:
# - prog01.c -> 1
# - prog03a.c -> 3a
# Though it's OK to write:
# - prog01a
# - 02b
# - prog02
# - 03.
# and so on.
file_name=1

# class number.
# Though it's OK to write like C6 and so on.
class=1

# Translating the exercise number, program file name, class number.
if [[ ! $ex_num =~ ^(ex)?[0-9][0-9]?$ ]]; then
	echo -e "Can\'t translate exercise number."
	exit 1
fi
if [[ ! $ex_num =~ ex ]]; then
	if [[ ! $ex_num =~ [0-9][0-9] ]]; then
		ex_num=ex0$ex_num
	else
		ex_num=ex$ex_num
	fi
else
	if [[ ! $ex_num =~ [0-9][0-9] ]]; then
		ex_num=${ex_num:0:2}"0"${ex_num:2:3}
	fi
fi
if [[ ! $file_name =~ ^(prog)?[0-9][0-9]?[a-z]?$ ]]; then
	echo -e "Can\'t translate source file name."
	exit 1
fi
if [[ ! $file_name =~ prog ]]; then
	if [[ ! $file_name =~ [0-9][0-9] ]]; then
		file_name=prog0$file_name
	else
		file_name=prog$file_name
	fi
else
	if [[ ! $file_name =~ [0-9][0-9] ]]; then
		file_name=${file_name:0:4}"0"${file_name:4:5}
	fi
fi
if [[ ! $class =~ ^C?[0-9]$ ]]; then
        echo -e "Can\'t translate class number."
	exit 1
fi
if [[ ! $class =~ C ]]; then
	class=C$class
fi

# About the directory and score file.
running_directory=$ex_num"_"$file_name"_"$class
scorefile_name="score_"$ex_num"_"$file_name"_"$class".txt"
mkdir $running_directory
cd $running_directory
rm $scorefile_name
for id in $(cat /home/course/prog1/local_html/2021/MkMember/Member$class)
do
	# If you have to prepare any other files than specified file_name, you can get the target files by adding the lines here. You can understand how to modify this part.
	cp /home/course/prog1/local_html/2021/exsrc/$ex_num/stulist01/$id.h stulist01.h

	echo '----------'$id'----------'
	score=0
	src_path_c="/home/course/prog1/local_html/2021/exsrc/$ex_num/$file_name/$id.c"
	cp $src_path_c .
	if [ -f $id.c ]; then
		score=$(($score+$file_exist_score))
	else
		echo "the score is 0"
		echo $id,0 >> $scorefile_name
		continue
	fi

	# compiling the program
	gcc $id.c -o $id.out
	if [ $? == 0 ]; then
		score=$(($score+$compilable_score))
	else
		echo "the score is $score"
		echo $id,$score >> $scorefile_name
		continue
	fi

	#Displaying the submitted source code.
	# If you don't have to read source codes, this line can be commentouted.
	cat stulist01.h
	cat $id.c

	# running the program
	echo -e $stdinstr | timeout 0.5s ./$id.out
	if [ $? != 0 ]; then
		echo "runtime error or timeout"
	fi
	# message interaction
	for ((i = 0; i < ${#msg[@]}; i++)) {
		read -n1 -p "${msg[i]}" yn
		echo ''
		if [[ $yn == $yes_char ]]; then
			score=$(($score+${part_score[i]}))
		fi
	}

	# append the total score
	echo "The score is $score."
	echo $id,$score >> $scorefile_name
done
