#!/bin/bash

export TIMING=1

source ./scan.sh

seq 61 120 | while read A
	do
		scanA $A
	done
