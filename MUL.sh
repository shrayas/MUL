#!/bin/bash

tflag=
lflag=
dflag=
iflag=
rflag=

while [ $# -gt 0 ]
do
	case "$1" in
		-t)	tflag=on
			manga=$2
			lastChapter=$3
			shift
			shift
			shift
			break;;

		-l) lflag=on
			break;;

		-d)	dflag=on
			manga=$2
			shift
			break;;

		-i)	iflag=on
			break;;

		-r) rflag=on
			manga=$2
			shift
			break;;
	esac

	shift
done

#echo $tflag "-" $lflag "-" $dflag "-" $iflag

if [ $tflag ]
then

	code=`curl -s -L -w %{http_code} -o /dev/null www.mangareader.net/$manga`
	
	if [ $code == "404" ]
	then
		echo "Manga : \"$manga\" not found. Are u sure it exists in the mangareader database?"
		exit 1
	fi

	if ! [ -f mangas ]
	then
		touch mangas
	fi

	echo "$manga|$lastChapter" >> mangas

	#echo "Gotcha! Manga: $manga | Last chapter read: $lastChapter"

elif [ $lflag ]
then

	cat mangas | while read LINE
	do
		manga=`echo $LINE | cut -d "|" -f1`
		lastChapter=`echo $LINE | cut -d "|" -f2`
		echo $manga ":" $lastChapter
	done

elif [ $dflag ]
then

	mv mangas mangas.old
	awk -v rem=$manga 'match($1,rem) == 0 {print $0}' mangas.old > mangas
	rm mangas.old

elif [ $iflag ]
then

	if [ -f mangas ]
	then
		rm mangas
	fi

elif [ $rflag ]
then

	lastChapter=$(grep -e $manga mangas | cut -d "|" -f2)
	
	$0 -d $manga
	$0 -t $manga $(($lastChapter + 1))

else

	cat mangas | while read LINE
	do
		manga=`echo $LINE | cut -d "|" -f1`
		lastChapter=`echo $LINE | cut -d "|" -f2`

		nextChapter=$(($lastChapter+1))

		result=$(curl -s www.mangareader.net/$manga | grep -e "/$nextChapter" | sed -n 1p | wc -l)

		if [ $result == "1" ]
		then
			echo -e "*new*\t $manga http://mangareader.net/$manga/$nextChapter"
		fi
	done

fi