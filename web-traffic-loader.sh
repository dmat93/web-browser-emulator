#!/bin/bash
if [ "$1" = "" ];
then
	echo " "
	echo "======================================================="
        echo "  Pass variable from command line in sequence:"
        echo "     1. List name"
	#echo "     2. Number of request () "
        echo "     2. Number of clients"
	echo "     3. Request Rate (requests per second)"
	echo "======================================================="
	echo "     4. Subnet to consider in the format X.X.X (don't use last dot)"
	echo "     5. Subnet mask to use in the format YY (without slash)"
	echo "     6. Device name to bind clients"
	echo "     7. Starting IP address to assign in the format ZZ "
        echo " "
	echo "  TO STOP THE SCRIPT PRESS  [ CTLR+Z ]"
	echo "======================================================="
	echo " "
else
	fn=$1
	cn=$2
	rr=$3
	subnet=$4
	mask=$5
	dev=$6
	sp=$7
	ln=$(wc -l $fn | awk '{print $1}')
	a=0
	echo "======================================================="
	echo "$cn clients will start $rr request per second"
	echo "======================================================="
	#
	./namespace-generator-purge.sh
	./namespace-generator.sh $cn $subnet $mask $dev $sp
	while true
	do
		a=$(expr $a + 1)
		for i in `seq 1 $rr`
		do
			website[$i]=$(sed -n $(shuf -i1-$ln -n1)p $fn);
		done
		ns=$(shuf -i1-$cn -n1)
		ip netns exec c$(echo $ns) chromium-browser --disk-cache-dir=/dev/null --disk-cache-size=1 --headless --disable-gpu --no-sandbox  --remote-debugging-port=9222 ${website[@]} 2>1 > /dev/null &
		if [ "$a" == "60" ]
		then
			pkill -f -- "chromium-browser --enable-pinch"
			clear
			echo "======================================================="
			echo "                   Reset done after 60s"
			echo "======================================================="
			a=0
		fi
		sleep 1
	done
fi
