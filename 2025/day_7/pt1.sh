#!/usr/bin/env bash

set_char_on_grid ()
{
    local -n _grid="${1}"; shift
    local -ri j="${1}"; shift
    local -ri i="${1}"; shift
    local -r char="${1}"; shift
    
    local -r l="${_grid[j]:0:i}"
    local -r r="${_grid[j]:$(( i + 1 ))}"
    _grid[j]="${l}${char}${r}"
}

main ()
{
    # args
    local -r input_file="${1}"; shift
    
    mapfile -t grid < "${input_file}"

    split_count=0
    timelines=1
    for ((j=1; j < "${#grid[@]}"; j++));do

        for ((i=0; i < "${#grid[0]}"; i++));do
            up_char="${grid[$(( j - 1 ))]:${i}:1}"
            curr_char="${grid[${j}]:${i}:1}"
            
            if [[ "$up_char" == '|' ]] || [[ "$up_char" == 'S' ]];then

                if [[ "$curr_char" == '^' ]];then
                    set_char_on_grid grid "$j" "$(( i - 1  ))" '|'
                    set_char_on_grid grid "$j" "$(( i + 1  ))" '|'
                    ((split_count++))
                else
                    set_char_on_grid grid "$j" "${i}" '|'
                fi
            fi


        done
    done

    echo "${split_count}"

}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "${@}"
