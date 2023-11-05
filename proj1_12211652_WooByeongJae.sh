#! /bin/bash

clear
echo "-----------------------"
echo "User Name: Woo Byeong Jae"
echo "Student Number: 12211652"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item’"
echo "3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’"
echo "4. Delete the ‘IMDb URL’ from ‘u.item"
echo "5. Get the data about users from 'u.user’"
echo "6. Modify the format of 'release date' in 'u.item’"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "-----------------------"

stop="N"
until [ $stop = "Y" ]
do
	read -p "Enter your choice [ 1-9 ] " request
	echo ""

	# command 1	
	if [ $request -eq 1 ]
	then
		read -p "Please enter 'movie id'(1~1682): " answer1
		echo ""
		cat u.item | awk -F\| -v ID=$answer1 '$1==ID {print $0}'
		echo ""
	
	# command 2
	elif [ $request -eq 2 ]
	then
		while :
		do
			read -p "Do you want to get the data of ‘action’ genre movies from 'u.item’?(y/n):" answer2
			if [ $answer2 = "y" ]
			then
				echo ""
				cat u.item | awk -F\| '$7==1 {print $1, $2}' | awk 'NR<=10 {print $0}'
				echo ""
				break
			elif [ $answer2 = "n" ]
			then
				echo ""
				break
			else
				echo "Invalid answer! Re-enter your request"
				echo ""
			fi
		done
	
	# command 3
	elif [ $request -eq 3 ]
	then
		read -p "Please enter 'movie id'(1~1682): " answer3
		echo ""
		quantity=$(cat u.data | awk -v ID=$answer3 '$2==ID {print $3}' | wc -l)
		sum=$(cat u.data | awk -v ID=$answer3 '$2==ID {print $3}' | awk '{sum += $1} END {print sum}')
		result=$(echo "$sum / $quantity" | bc -l)
		printf "average rating of %d: %.5f\n\n" "$answer3" "$result"

	# command 4
	elif [ $request -eq 4 ]
	then
		while :
		do
			read -p "Do you want to delete the ‘IMDb URL’ from ‘u.item’?(y/n):" answer4
			if [ $answer4 = "y" ]
			then
				echo ""
				cat u.item | awk 'NR<=10 {print $0}' | sed -E 's/http[^\|]*\|/\|/g'
				break
			elif [ $answer4 = "n" ]
			then
				break
			else
				echo "Invalid answer! Re-enter your request"
				echo ""
			fi
		done
	
	# command 5
	elif [ $request -eq 5 ]
	then
		while :
		do
			read -p "Do you want to get the data about users from ‘u.user’?(y/n)" answer5
			if [ $answer5 = "y" ]
			then
				cat u.user | awk -F\| 'NR<=10 {print $1, $2, $3, $4}' > temp.txt
				cat temp.txt | sed -E 's/^/user /g' > temp2.txt
				cat temp2.txt | sed -E 's/\s/ is /2' > temp.txt
				cat temp.txt | sed -E 's/\s/ years old /4' > temp2.txt
				cat temp2.txt | sed -E 's/M/male/g' > temp.txt
				cat temp.txt | sed -E 's/F/female/g' > temp2.txt
				echo ""; cat temp2.txt; echo "";
				rm temp.txt temp2.txt
				break
			elif [ $answer5 = "n" ]
			then
				break
			else
				echo "Invalid answer! Re-enter your request"
				echo ""
			fi
		done

	# command 6
	elif [ $request -eq 6 ]
	then
		while :
		do
			read -p "Do you want to Modify the format of ‘release data’ in ‘u.item’?(y/n)" answer6
			if [ $answer6 = "y" ]
			then
				cat u.item | awk -F\| '$1>=1673 && $1<=1682 {print $0}' > temp.txt
				cat temp.txt | sed -E 's/([0-9]{2})-[a-zA-Z]{3}-([0-9]{4})/\2\1/g' > temp2.txt
				echo ""; cat temp2.txt; echo ""
				rm temp.txt; rm temp2.txt
				break
			elif [ $answer6 = "n" ]
			then
	            break
	        else
	            echo "Invalid answer! Re-enter your request"
				echo ""
			fi
		done

	# command 7
	elif [ $request -eq 7 ]
	then
		read -p "Please enter the ‘user id’(1~943):" answer7
		cat u.data | awk -v ID=$answer7 '$1==ID {print $2}' | sort -n > temp.txt
		cat temp.txt | awk '{printf "%d|", $1} END {printf "\n"}' > temp2.txt
		cat temp2.txt | sed -E 's/\|$//g' > horizon.txt
		echo ""; cat horizon.txt; echo "";

		n=0
		while [ $((++n)) -le 10 ]
		do
			value=$(cat temp.txt | sed -n '1p')
			cat u.item | awk -F\| -v indexValue=$value '$1==indexValue {printf "%s|%s\n", $1, $2}'
			cat temp.txt | sed '1d' > temp2.txt
			cat temp2.txt > temp.txt
		done
		rm temp.txt; rm temp2.txt; rm horizon.txt
		echo "";

	# command 8
	elif [ $request -eq 8 ]
	then
		read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):" answer8
		if [ $answer8 = "y" ]
		then
			echo ""
			cat u.user | awk -F\| '$2>=20 && $2<30 && $4=="programmer" {print $1}' > userId.txt
			n=0
			count=$(cat userId.txt | wc -l)
			while [ $((++n)) -le $count ]
			do
				userId=$(cat userId.txt | sed -n '1p')
				cat u.data | awk -v userid=$userId '$1==userid {print $0}' >> movieList.txt
				cat userId.txt | sed '1d' > temp.txt
				cat temp.txt > userId.txt
			done
			count=$(cat u.item | wc -l)
			n=0
			while [ $((++n)) -le $count ]
			do
				cat movieList.txt | awk -v movieId=$n '$2==movieId {print $0}' > temp.txt
				dataCount=$(cat temp.txt | wc -l)
				if [ $dataCount -eq 0 ]; then
					continue
				fi
				result=$(cat temp.txt | awk -v movieIndex=$n -v denominator=$dataCount '{sum+=$3} END {print sum/denominator}')
				echo $n $result
			done
			rm movieList.txt; rm temp.txt; rm userId.txt
		elif [ $answer8 = "n" ]
		then
			break
		else
			echo "Invalid answer! Re-enter your request"
			echo ""
		fi

	# command 9
	elif [ $request -eq 9 ]
	then
		echo "Bye!"
		echo ""
		stop="Y"
	# command InputException
	else
		echo "Invalid answer! Only one of 1-9 integers is allowed"
	fi
done
