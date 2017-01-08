#!/bin/bash

export TIMING=1

source ./scan.sh

seq 1 60 | while read A
	do
		scanA $A
	done
