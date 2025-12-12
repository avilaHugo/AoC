#!/usr/bin/env bash

set -f # IMPORTANT: turn glob('*') off

main() {
    # args
    local -r input_file="${1}"; shift

    declare -a cols_lengths

    mapfile -t lines < "${input_file}"
    
    for ((i=0; i < "${#lines[@]}"; i++));do
        nums=( ${lines[$i]} )

        for ((j=0; j < "${#nums[@]}"; j++));do
            curr_col_len="${cols_lengths[j]}"
            new_col_len="${#nums[j]}"

            if (( new_col_len > curr_col_len ));then
                cols_lengths[j]="${new_col_len}"
            fi
        done
    done
    
    line_pos=0
    for ((i=0; i < "${#cols_lengths[@]}"; i++));do

        col_len="${cols_lengths[i]}"

        declare -a blocks=()
        for ((j=0; j < "${#lines[@]}"; j++));do
            blocks+=( "${lines[$j]:${line_pos}:${col_len}}" )
        done

        op="${blocks[-1]// /}"
        # printf '%s\n' "${blocks[@]@Q}"
        unset 'blocks[${#blocks[@]}-1]'

        declare -a joinned=()

        for ((col_i="$(( ${#blocks[0]} - 1 ))"; col_i >=0; col_i--));do
            number=""
            for ((row_i=0; row_i < ${#blocks[@]}; row_i++));do
                number+="${blocks[$row_i]:${col_i}:1}"
            done
            joinned+=( "${number}"  )
        done
        sed -r 's:^ +::; s: +$::g; s: +:'${op}':g; s:^(.+)$:(\1):;' <<<  "${joinned[@]}" 

        (( line_pos += (col_len+1) ))    

    done \
        | head \
        | paste -sd+ \
        | bc



    
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "${@}"
