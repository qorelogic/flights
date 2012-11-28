#!/bin/bash

from="bue sao mad rio lon mia dxb lim ccs bog scl mvd"
to="dar nbo jnb mad rio cpt lon mia dxb lim ccs bog scl mvd"

cacheDir="./cache"

printUsage() {
	#echo "usage: <fromdate[format=ddmmyyyy]>"
	echo "usage: <fromdate[format=yyyy-mm-dd]>"
}

check() {
	echo $1
	if [ "$1" == "" ]; then
		printUsage
		return 0
	else
		if [ "$1" == "" ]; then
			printUsage
		else
			mdateFrom="$1"
			mdateTo="$1"
		fi
	fi

	if [ "$1" != "" ]; then
		echo 1
		#return 1
	else
		echo 0
		#return 0
	fi
}
check $1

	
makeFurl() {
	furl="`echo $1 | perl -pe 's/\//-/g' | perl -pe 's/:/-/g' `.html"
	echo $furl
}

findFlights() {
mode="$1"
if [ "$mode" == "fixed-date" ]; then
for f in $from; do
	for t in $to; do	
		echo -n "fetching data... "
		
		#furl="http://m.despegar.com.ar/vuelos/oneway/c-${f}/c-${t}/$mdateFrom/$mdataTo/1/0/0/i1"
		furl="http://m.despegar.com.ar/vuelos/oneway/c-${f}/c-${t}/${mdateFrom}/${mdateTo}/1/0/0/i1"
		
		#furl="http://www.despegar.com.ar/shop/flights/results/oneway/${f}/${t}/${mdateFrom}/1/0/0"
		#echo $furl

		fname="`makeFurl $furl`"
		
		wget -qO - $furl  > $cacheDir/$fname
		echo "  saved to $cacheDir/$fname"
		echo -n "from: $f "
		echo -n "to: $t --> U\$D "
		
		parseDespegarComHTML $cacheDir/$fname
		#sleep 20
		echo "----"
	done
done
fi
if [ "$mode" == "fixed-route" ]; then
#	for iYear in `seq 2012 2014`; do
		#currentMonth="`date +'%m'`"
#		for jMonth in `seq 1 12`; do
		
#			for kDay in `seq 1 31`; do

				
#				iYear="`python -c \"
#import string as st
#print st.zfill('$iYear', 4)
#\"`"
#				jMonth="`python -c \"
#import string as st
#print st.zfill('$jMonth', 2)
#\"`"
#				kDay="`python -c \"
#import string as st
#print st.zfill('$kDay', 2)
#\"`"
	for iRange in `seq 2 100`; do
				c=$(date -d "+$iRange days")
				mdate=$(date -d "$c" +"%Y-%m-%d")
				#mdate="$iYear-$jMonth-$kDay"
				
				f="bue"
				t="dar"
				mdateFrom="$mdate"
				mdateTo="$mdate"
				
				#furl="http://m.despegar.com.ar/vuelos/oneway/c-${f}/c-${t}/$mdateFrom/$mdataTo/1/0/0/i1"
				furl="http://m.despegar.com.ar/vuelos/oneway/c-${f}/c-${t}/${mdateFrom}/${mdateTo}/1/0/0/i1"
				echo $furl
				
				fname="`makeFurl $furl`"
				
				wget -qO - $furl  > $cacheDir/$fname
				echo "  saved to $cacheDir/$fname"
				echo -n "from: $f "
				echo -n "to: $t --> U\$D "
				
				parseDespegarComHTML $cacheDir/$fname
				echo "----"
#			done
#		done
#	done
	done
fi
}

parseDespegarComHTML() {
	if [ "$1" == "" ]; then
		echo "usage: <cache fname>"
	else
		fname="$1"
		#echo $fname
		#pm="`cat $cacheDir/$fname | lynx -stdin -dump | grep -C2 '\$' | grep '\$' | grep 'vuelo' | cut -d' ' -f12 | perl -pe 's/\.//g'`"
		#pm="`cat $cacheDir/$fname | lynx -stdin -dump | grep -C2 '\$' | grep '\$' | grep 'vuelo' | perl -pe 's/.*\$.*?([\d\.]+).*/\1/g' | perl -pe 's/\.//g'`"
		cat $fname 2> /dev/null | lynx -stdin -dump | grep -C2 '\$' | grep '\$' | grep 'vuelo' | perl -pe 's/.*\$.*?([\d\.]+).*?/\1/g' | perl -pe 's/\.//g' | head -1
		#echo $pm
		#let cnt=0
		#for i in `echo $pm`; do
			#echo $cnt
			#if [ "$cnt" != "0" ]; then # all prices
		#	if [ "$cnt" == "1" ]; then # only first price
		#		echo $i
		#	fi
		#	let cnt=$cnt+1
		#done
	fi
}

parseAllFilesDespegarComHTML() {
	if [ "$1" == "" ]; then
		#echo "usage: <cache fname>"
		echo "From,To,Date,Currency,Price"
		for i in `ls $cacheDir/http*`; do
				fname="$i"
				from="`echo $fname | perl -pe 's/.*-c-(.*?)-c-(.*?)-.*/\1/g'`"
				to="`echo $fname | perl -pe 's/.*-c-(.*?)-c-(.*?)-.*/\2/g'`"
				mdate="`echo $fname | perl -pe 's/.*([\d]{4}-[\d]{2}-[\d]{2}).*/\1/g'`"
				r="`parseDespegarComHTML $fname`"
				if [ "$r" != "" ]; then
					echo -n "$from,$to,$mdate,USD,"
					echo $r | perl -pe 's/ /,/g'
				fi
		done
	else
		echo 'stub'
	fi
}

getDistance() {
	f="$1"
	t="$2"
	furl="http://m.despegar.com.ar/vuelos/oneway/c-${f}/c-${t}/${mdateFrom}/${mdateTo}/1/0/0/i1"
	fname="`makeFurl $furl`"
	
	pm="`parseDespegarComHTML $cacheDir/$fname`"
	echo $pm
}

getTicketPrice() {
	f="$1"
	t="$2"
	furl="http://m.despegar.com.ar/vuelos/oneway/c-${f}/c-${t}/${mdateFrom}/${mdateTo}/1/0/0/i1"
	fname="`makeFurl $furl`"
	
	pm="`parseDespegarComHTML $cacheDir/$fname`"
	echo $pm
}

routeCalc() {
	from="bue"
	to="dar"
	# find the cheapest route
	echo "$from-$to: `getTicketPrice "bue" "dar"`"
	echo "$from-$to: `getTicketPrice "bue" "rio"`"
	
	python -c "
from='$from'
to='$to'

dst.update({str(from + to):'`getTicketPrice "bue" "dar"`'})
print dst
"
}

#findFlights
#parseDespegarComHTML
