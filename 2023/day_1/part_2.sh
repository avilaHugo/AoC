#!/usr/bin/env bash

# strict mode
set -euo pipefail

get_first_and_last_digit_from_string() {
    local s="${*}"
    s="${s//[[:alpha:]]/}"
    echo "${s:0:1}${s:$((${#s}-1)):1}"
}

convert_all_spellout_numbers_to_digit() {
    local s="${*}"
    while [[ ${s} =~ ${NUM_MAP_PATTERN} ]]; do
        s="${s/${BASH_REMATCH[0]}/${NUM_MAP[${BASH_REMATCH[0]}]}}"
    done
    echo "${s}"
}

# Some constants 
declare -r -A NUM_MAP=(
    # This was not my ideia i stole it from reddit,
    # solution for the "eightwo" problem:
	["zero"]="z0o"
	["one"]="o1e"
	["two"]="t2o"
	["three"]="t3e"
	["four"]="f4r"
	["five"]="f5e"
	["six"]="s6x"
	["seven"]="s7n"
	["eight"]="e8t"
	["nine"]="n9e"
)

# This is to get "one|two|three..." to use as regex pattern
NUM_MAP_PATTERN="$(IFS='|'; echo "${!NUM_MAP[*]}")"

# "MAIN"
declare -i RESULT
while read -r f;do
    RESULT+=$(get_first_and_last_digit_from_string $(convert_all_spellout_numbers_to_digit ${f}))
done < "${1}"
echo "${RESULT}"



    
