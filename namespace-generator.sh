#!/bin/bash
# remember awk -F. '{print ($X)}' set the delimiter as a dot "." and print the X-th coloumn
if [ "$1" = "" ]
then
        echo " ========================================= "
        echo " > Parameter to pass"
        echo " > 1. Number of clients [int]"
        echo " > 2. Subnet to consider in the format X.X.X (don't use last dot)"
	echo " > 3. Subnet mask in the format XX  (don't use slash)"
        echo " > 4. Device name to bind the clients"
	echo " > 5. Starting IP address assignment in the format YYY"
        echo " ========================================= "
else
cn=$1
subnet=$2
mask=$3
dev=$4
sp=$5
if [ "$cn" -gt "$(expr 255 - 3 - $sp - 1)" ]
then
	$cn=$(expr 255 - 3 - $sp)
fi

for i in `seq 1 $cn`
        do
		sub=$(echo $subnet | awk -F. '{print $NF}')
                # Create veth pair
		ip link add veth$sub-$i type veth peer name veth$sub-$i-ns
                # Create NS
                ip netns add c$i
                # Move veth in the NS
                ip link set veth$sub-$i-ns netns c$i
                # Swith on interfaces
                ip link set veth$sub-$i up
                ip netns exec c$i ip link set veth$sub-$i-ns up
                ip netns exec c$i ip link set lo up
                # Assign IP addresses to the veth
                ip addr add 10.0.$i.1/24 dev veth$sub-$i
                ip netns exec c$i ip addr add 10.0.$i.2/24 dev veth$sub-$i-ns
		# Assign secondary IP address to the phyNIC
		ip addr add $subnet.$(expr $sp + $i - 1)/$mask dev $dev
                # Set default route for the NS
                ip netns exec c$i ip route add default via 10.0.$i.1
		# IPTABLES configuration
		iptables -t nat -I POSTROUTING -s 10.0.$i.0/24 -o $dev -j SNAT --to $subnet.$(expr $sp + $i - 1)
                iptables -t nat -I PREROUTING -d $subnet.$(expr $sp + $i - 1)/$mask -i $dev -j DNAT --to 10.0.$i.2
        done
fi
