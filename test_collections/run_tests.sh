#!/bin/bash

function run_test {
	SRC_FILE=$1
	COLLECTION_NAME=$2
	MAX_CAPACITY=$3

	BASE_OUT=results
	mkdir -p ${BASE_OUT}

	BINDIR=bin-${COLLECTION_NAME}-`uname`-`arch`
	OUT_FILE=${BASE_OUT}/${COLLECTION_NAME}-${MAX_CAPACITY}-${SRC_FILE}.txt

	$BINDIR/$SRC_FILE $MAX_CAPACITY > $OUT_FILE
}

# Hash tests
for f in hash_maps_test hash_maps_test2 hash_maps_test5
do
	for c in chaining open
	do
		for m in 50 10 7
		do
			echo "-- Running $f with $c library and a max capacity of $m --"
			run_test $f $c $m
		done
		echo
	done
done

# Ordered test
echo "-- Running ordered_test with a max capacity of 50 --"
run_test ordered_test ordered 50

