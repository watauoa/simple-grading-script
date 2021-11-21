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
stdinstr="C1 202111 Sota   91\n"

# Meanings of the file_exist_score and the compilable_score is obvious.
# Those variables are about partial part interaction. 
# The msg is the sentence that will be displayed in the interaction. Those sentences are up to you, so it's OK to write like msg=("1" "2" "3") if you know what the numbers mean.
# The meaning of part_score is obvious. The order of the numbers corresponds to the order of msg.
# The file_to_check is the file paths that should be checked when the score interaction. The keyword "src" and "out" is acceptable. The "src" is the source code file. The "out" is the output texts. If you should check multiple files, those files can be specified by colon separated value.
# The re_str and re_cnt will be used to grade files with regex. If the re_check is empty, this function never work. TODO: more explanation.
file_exist_score=20
compilable_score=20
msg=("Is the output is OK?")
part_score=(60)
file_to_check=("out")
re_separator=":::"
re_str=("C1 +202111 +Sota +91")
re_cnt=(1)

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
# Though it's OK to write like C6, c3 and so on.
class=2

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
		ex_num=${ex_num:0:2}"0"${ex_num:2:1}
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
		file_name=${file_name:0:4}"0"${file_name:4:1}
	fi
fi
if [[ ! $class =~ ^[cC]?[0-9]$ ]]; then
        echo -e "Can\'t translate class number."
	exit 1
fi
if [[ $class =~ c ]]; then
	class=C${class:1:1}
elif [[ ! $class =~ c ]]; then
	class=C$class
fi

# About the directory and score file.
running_directory=$ex_num"_"$file_name"_"$class
scorefile_name="score_"$ex_num"_"$file_name"_"$class".txt"
mkdir $running_directory
cd $running_directory
rm $scorefile_name
mkdir src
mkdir elf
mkdir out
for id in $(cat /home/course/prog1/local_html/2021/MkMember/Member$class)
do
	# If you have to prepare any other files than specified file_name, You can get the target files by adding the lines here. You can understand how to modify this part.
	cp -P /home/course/prog1/public_html/2021/ex/$ex_num/* .

	echo '----------'$id'----------'
	score=0
	cp /home/course/prog1/local_html/2021/exsrc/$ex_num/$file_name/$id.c ./src
	echo -n "File Exist: "
	if [ -f src/$id.c ]; then
		echo "Yes. $file_exist_score points was added."
		score=$(($score+$file_exist_score))
	else
		echo "No."
		echo "The final score is 0"
		echo $id,0 >> $scorefile_name
		continue
	fi
	echo "The current score is $score."

	# compiling the program
	cp src/$id.c ${file_name}.c
	echo -n "Compile: "
	gcc ${file_name}.c -o elf/$id.elf 2> /dev/null
	if [ $? == 0 ]; then
		echo "Successed. $compilable_score points was added."
		score=$(($score+$compilable_score))
	else
		echo "Failed."
		echo "The final score is $score"
		echo $id,$score >> $scorefile_name
		continue
	fi
	echo "The current score is $score."

	# running the program
	cp elf/$id.elf ./${file_name}.elf
	echo -e $stdinstr | timeout 0.5s ./${file_name}.elf > out/$id.out
	if [ $? != 0 ]; then
		echo "runtime error or timeout"
	fi
	# message interaction
	# TODO: more tests.
	for ((i = 0; i < ${#msg[@]}; i++)) {
		get_score=false
		if [[ "${file_to_check[i]}" == "src" ]]; then
			file_to_check[i]=./src/$id.c
		fi
		if [[ "${file_to_check[i]}" == "out" ]]; then
			file_to_check[i]=./out/$id.out
		fi
		re_str_elm=""
		re_str_ext=${re_str[i]}
		re_cnt_elm=""
		re_cnt_ext=${re_cnt[i]}
		while [[ $re_str_elm != $re_str_ext ]]; do
			re_str_elm=${re_str_ext%%${re_separator}*}
			re_str_ext=${re_str_ext#*${re_separator}}
			re_cnt_elm=${re_cnt_ext%%,*}
			re_cnt_ext=${re_cnt_ext#*,}
			match_cnt=$(cat ${file_to_check[i]} | grep -P "$re_str_elm" | wc -l)
			if [[ $re_str_elm != "" ]]; then
				if [[ $match_cnt == $re_cnt_elm]]; then
					get_score=true
					continue
				fi
			fi
		done
		if [[ $get_score ]]; then
			score=$(($score+${part_score[i]}))
			continue
		fi
		echo "display $file_to_check."
		cat ${file_to_check[i]}
		read -n1 -p "${msg[i]}" yn
		echo ''
		if [[ $yn == $yes_char ]]; then
			score=$(($score+${part_score[i]}))
		fi
	}

	# appending the total score
	echo "The score is $score."
	echo $id,$score >> $scorefile_name
done
