#!/usr/bin/env bash


main() {
    # args
    local -r input_file="${1}"; shift

    local -i cols="$( perl -pe 's: +: :g' ${input_file} | awk '{print NF; exit}' )"

    echo "COLS: ${cols}"

    for i in $(seq 1 "$cols");do
        mapfile -t arr < <( perl -pe 's: +: :g' ${input_file}  | awk '{print $'$i' }' | perl -pe 's:\+:SUM:g; s:\*:MUL:g;' )
        echo "${arr[@]:0:$(( ${#arr[@]} -1  ))}" | sed 's: : '"${arr[-1]}"' :g; s:SUM:+:g; s:MUL:*:g;' | bc
    done \
        | paste -sd+ \
        | bc


    
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "${@}"
