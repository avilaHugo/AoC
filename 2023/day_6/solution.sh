#!/usr/bin/env bash

part_1::format_input() {
    paste -d' ' <( head -1 | tr -s '[[:space:]]+' '\n' ){,} \
        | sed '1d'
}

part_2::format_input() {
    tr -cd '[[:digit:]\n]' | paste - - 
}

# USAGE: solution.sh < sample.txt

# WARNIG: this is a naive solution, large inputs
#         might overflow your memory.

# For part one just replace this function 
# for the part_1::format_input.
part_2::format_input \
    | while read -r TIME DISTANCE;do
        MAX_PRESS_TIME=$(( TIME - 1  ))
        seq "${MAX_PRESS_TIME}" \
            | sed -r 's:(.*):(\1*('${TIME}'-\1))>'${DISTANCE}':' \
            | bc \
            | awk '{sum+=$0} END {print sum}'
      done \
      | awk -v sum=1 '{sum*=$0} END {print sum}'
