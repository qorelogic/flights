#!/bin/bash

from="bue sao mad rio lon mia dxb lim ccs bog scl mvd"
to="dar nbo jnb mad rio cpt lon mia dxb lim ccs bog scl mvd"

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
for f in $from; do
	for t in $to; do	
		echo -n "fetching data... "
		
		#furl="http://m.despegar.com.ar/vuelos/oneway/c-${f}/c-${t}/$mdateFrom/$mdataTo/1/0/0/i1"
		furl="http://m.despegar.com.ar/vuelos/oneway/c-${f}/c-${t}/${mdateFrom}/${mdateTo}/1/0/0/i1"
		
		#furl="http://www.despegar.com.ar/shop/flights/results/oneway/${f}/${t}/${mdateFrom}/1/0/0"
		#echo $furl

		fname="`makeFurl $furl`"
		
		wget -qO - $furl  > $fname		
		echo "  saved to $fname"
		echo -n "from: $f "
		echo -n "to: $t --> U\$D "
		
		parseDespegarComHTML $fname
		#sleep 20
		echo "----"
	done
done
}

parseDespegarComHTML() {
	if [ "$1" == "" ]; then
		echo "usage: <cache fname>"
	else
		fname="$1"
		#echo $fname
		pm="`cat $fname | lynx -stdin -dump | grep -C2 '\$' | grep '\$' | grep 'vuelo' | cut -d' ' -f12 | perl -pe 's/\.//g'`"
		let cnt=0
		for i in `echo $pm`; do
			#echo $cnt
			#if [ "$cnt" != "0" ]; then # all prices
			if [ "$cnt" == "1" ]; then # only first price
				echo $i
			fi
			let cnt=$cnt+1
		done
	fi
}

parseAllFilesDespegarComHTML() {
	if [ "$1" == "" ]; then
		#echo "usage: <cache fname>"
		echo "FileName,From,To,Price"
		for i in `ls http*`; do
				fname="$i"
				from="`echo $fname | perl -pe 's/.*-c-(.*?)-c-(.*?)-.*/\1/g'`"
				to="`echo $fname | perl -pe 's/.*-c-(.*?)-c-(.*?)-.*/\2/g'`"
				echo -n "$fname,$from,$to,"
				r="`parseDespegarComHTML $fname`"
				echo $r | perl -pe 's/ /,/g'
		done
	else
#	for f in $from; do
#		for t in $to; do	
	for i in `ls http*`; do
			#echo -n "despegar.com "
			#echo -n "from: $f "
			#echo -n "to: $t "
			#fname="cache-from-${f}-to-${t}.despegar.com.html"
			fname="$1"
			#echo "$fname "
			#echo "fetching data..."
			cat $fname  | lynx -stdin -dump | grep -C2 '\$' | grep '\$' | grep 'vuelo' 
#		done
	done
	fi
}

getDistance() {
	f="$1"
	t="$2"
	furl="http://m.despegar.com.ar/vuelos/oneway/c-${f}/c-${t}/${mdateFrom}/${mdateTo}/1/0/0/i1"
	fname="`makeFurl $furl`"
	
	pm="`parseDespegarComHTML $fname`"
	echo $pm
}

getTicketPrice() {
	f="$1"
	t="$2"
	furl="http://m.despegar.com.ar/vuelos/oneway/c-${f}/c-${t}/${mdateFrom}/${mdateTo}/1/0/0/i1"
	fname="`makeFurl $furl`"
	
	pm="`parseDespegarComHTML $fname`"
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