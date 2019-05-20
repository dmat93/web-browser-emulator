#!/bin/bash
z=10
for i in `seq 1 $z`
do
	pid=$(ps -aux | grep "$1" | sed -n 1p | awk '{print $2}')
	kill -15 $pid
done
