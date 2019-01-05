#!/bin/bash

function build_test {
	SRC_FILE=$1
	COLLECTION_NAME=$2

	BINDIR=bin-${COLLECTION_NAME}-`uname`-`arch`
	COLLECTION_PATH=../hash_maps_g_${COLLECTION_NAME}

	OUT_FILE=$BINDIR/$SRC_FILE

	mkdir -p $BINDIR
	gnatmake -D $BINDIR -I$COLLECTION_PATH -o $OUT_FILE $SRC_FILE
}

function build_ordered_test {
	SRC_FILE=$1
	COLLECTION_NAME=ordered

	BINDIR=bin-${COLLECTION_NAME}-`uname`-`arch`
	COLLECTION_PATH=../ordered_maps_g

	OUT_FILE=$BINDIR/$SRC_FILE

	mkdir -p $BINDIR
	gnatmake -D $BINDIR -I$COLLECTION_PATH -o $OUT_FILE $SRC_FILE
}

# Compile hash tests
for f in hash_maps_test hash_maps_test2 hash_maps_test5
do
	for c in chaining open
	do
		echo "-- Building $f with $c library --"
		build_test $f $c
		echo
	done
done

# Compile ordered_test
build_ordered_test ordered_test

