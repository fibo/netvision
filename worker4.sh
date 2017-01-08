#!/bin/bash

export TIMING=1

source ./scan.sh

seq 181 255 | while read A
	do
		scanA $A
	done

