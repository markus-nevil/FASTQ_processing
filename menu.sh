#! /bin/bash

## making bold and normal text
bold=$(tput bold)
normal=$(tput sgr0)
red=$(tput setaf 1)


## make new directory for aligned reads
#mkdir ./aligned_reads

## get list of input files
#files=./trimmed_reads/*.fastq


# ----------------------------------
# Step #2: User defined function
# ----------------------------------
pause(){
  read -p "Press [Enter] key to continue..." fackEnterKey
}

one(){
	echo "one() called"
        #pause
}
two(){
	echo "two() called"
        #pause
}
three(){
	echo "three() called"
        #pause
}
four(){
	echo "four() called"
        #pause
}
five(){
	echo "five() called"
        #pause
}

# function to display menus
show_menus() {
	echo "${red}~~~~~~~~~~~~~~~~~~~~~"	
	echo " M A I N - M E N U"
	echo "~~~~~~~~~~~~~~~~~~~~~${normal}"
	echo "1. Concatinate FASTQ files"
	echo "2. Trim FASTQ files"
	echo "3. Map FASTQ files"
	echo "4. Filter SAM files"
	echo "5. Make bedgraphs and bigWigs"
}

#Get user in put and invoke choices
read_options(){
	local startChoice
	local endChoice
	local badInput=true

	while $badInput
	do
	read -p "At what step would you like to begin?  " startChoice
	read -p "At what step would you like to end?  " endChoice
	local bad=true
	echo $bad
	echo $badInput
	if test $startChoice -lt 1 -o $startChoice -gt 5 -o $startChoice -gt $endChoice
		then
		echo "Check your starting choice, I don't recognize a menu option"
		bad=false
	fi
	if test $endChoice -lt 1 -o $endChoice -gt 5 -o $endChoice -lt $startChoice
		then
		echo "Check your ending choice, I don't recognize a menu option"
		bad=false
	fi
	echo $bad
	if  $bad 
		then
		echo "IF STATEMENT"
		badInput=false
		fi
	echo $badInput
	done

	local counter="$(($endChoice-$startChoice+1))"
	until [ $counter -lt 1 ]
	do
		if test $startChoice -eq 1
		then
			one
		fi
		if test $startChoice -eq 2
		then
			two
		fi
		if test $startChoice -eq 3
		then
			three
		fi
		if test $startChoice -eq 4
		then
			four
		fi
		if test $startChoice -eq 5
		then
			five
		fi
		if test ! $startChoice -eq $endChoice
		then
		startChoice="$((startChoice+1))"
		fi

		counter="$(($counter-1))"
		sleep 1
	done
	

}
 
## Step #3: Trap CTRL+C, CTRL+Z and quit singles
trap '' SIGINT SIGQUIT SIGTSTP
 
## Main loop
clear
echo "Starting up..."

while true
do
 
	show_menus
	read_options
done
