#!/usr/bin/env bash

# USAGE: solution.sh < sample.txt

alpha_to_number(){
	local HAND="${1}"

	for ((i=0; i<"${#HAND}"; i++));do
		echo "${HAND:${i}:1}"
	done \
	| sed '
		s:A:14:;
		s:K:13:;
		s:Q:12:;
		s:J:11:;
		s:T:10:;
	'
}

part_1::solution() {
    # Part 1
    while read -r HAND BID;do
        read -d '' -r CONVERTED_SYMBOLS < <(alpha_to_number "${HAND}")
        read -r PAIRS < <(awk '{d[$0]++} END {for (i in d) print d[i]}' <<< "${CONVERTED_SYMBOLS}" \
            | sort -nr \
            | tr -d '\n' \
            && echo)

        echo "${HAND} ${BID} ${PAIRS} ${CONVERTED_SYMBOLS//$'\n'/ }"
    done 
}

part_2::solution() {
    # Part 2
    while read -r HAND BID;do
        read -d '' -r CONVERTED_SYMBOLS < <(alpha_to_number "${HAND}" | sed 's:11:J:' )
        read -d '' -r CONVERTED_SYMBOLS_NO_JOKER < <( grep -v J <<< "${CONVERTED_SYMBOLS}" )

        read -r PAIRS < <(awk '/[[:digit:]]/ {d[$0]++} END {for (i in d) print d[i]}' <<< "${CONVERTED_SYMBOLS_NO_JOKER}" \
            | sort -nr \
            | tr -d '\n' \
            && echo)
        
        if [[ "${HAND}" =~ [J]+ ]];then
            JOKER_PAIR=$(( ${PAIRS:0:1} + $( grep -Pc J <<< ${CONVERTED_SYMBOLS}  ) ))
            PAIRS="${JOKER_PAIR}${PAIRS:1}"
        fi

        echo "${HAND} ${BID} ${PAIRS} $( tr '\n' ' ' <<< ${CONVERTED_SYMBOLS//J/1} )"
    done
}

# MAIN
# part_1::solution \
part_2::solution \
	| sort -k3,3 -k{4..8}n  \
	| awk '{sum+=(NR*$2)} END {print sum}'
