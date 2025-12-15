#!/usr/bin/env bash

declare -a grid

set_char_on_grid ()
{
    local -ri j="${1}"; shift
    local -ri i="${1}"; shift
    local -r char="${1}"; shift
    
    local -r l="${grid[j]:0:i}"
    local -r r="${grid[j]:$(( i + 1 ))}"
    grid[j]="${l}${char}${r}"
}

declare -A timelines

count_paths ()
{
    local -ri j="${1}"; shift
    local -ri i="${1}"; shift

    local -r node="${j},${i}"
    
    curr_char="${grid[${j}]:${i}:1}"

    if [[ -v 'timelines[${node}]' ]];then
	return
    fi

    if (( j == "${#grid[@]}" ));then
	timelines[${node}]=1
	return
    fi

    if [[ "$curr_char" == @(S|\|) ]];then
	count_paths $((j + 1)) "${i}"
	timelines[${node}]="${timelines[$((j + 1)),${i}]}"
	return
    fi

    if [[ "$curr_char" == '^' ]];then
	count_paths ${j} $(( i - 1 ))
	count_paths ${j} $(( i + 1 ))
	l="${timelines[${j},$((i - 1))]}"
	r="${timelines[${j},$((i + 1))]}"
	timelines[${node}]="$((l + r))"
	return
    fi

}

find_char_on_str ()
{
    local -r s="${1}"; shift
    local -r c="${1}"; shift

    for ((i=0; i < "${#s}"; i++));do
        if [[ "${s:${i}:1}" == "${c}" ]];then
            echo "${i}"
            return
        fi
    done
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
                    set_char_on_grid "$j" "$(( i - 1  ))" '|'
                    set_char_on_grid "$j" "$(( i + 1  ))" '|'
                    ((split_count++))
                else
                    set_char_on_grid "$j" "${i}" '|'
                fi
            fi
        done
    done

    S_j=0
    S_i=$( find_char_on_str "${grid[0]}" 'S' )

    count_paths "${S_j}" "${S_i}"
    echo ${timelines["${S_j},${S_i}"]}

}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "${@}"
