#!/bin/bash

all='default gnu oldgnu pax posix ustar v7 blocksizemax 2015'
for ref in $all; do
	for f in $all; do
		if [ "$ref" = "$f" ]; then continue; fi
		[ -d "diffs/$ref" ] || mkdir -- "diffs/$ref"
		sdiff -w166 <(hexdump -C data-${ref}.tar) <(hexdump -C data-${f}.tar) > diffs/${ref}/${f}.diff
	done
done

