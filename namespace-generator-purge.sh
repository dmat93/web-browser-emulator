#!/bin/bash
line=$(ip netns | awk '{print $1}' | wc -l)
for i in `seq 1 $line`
do
	c=$(ip l | grep veth | sed -n 1p | awk '{print substr($2,5,1)}')
	ip link del veth$c-$i
	ns=$(ip netns | awk '{print $1}' | sed -n 1p)
	ip netns del c$i
done
iptables -t nat -F POSTROUTING
iptables -t nat -F PREROUTING
iptables-restore < ./iptables.bak
