#!/bin/bash

export TIMING=1

source ./scan.sh

seq 120 180 | while read A
	do
		scanA $A
	done

