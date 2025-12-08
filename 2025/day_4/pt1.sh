#!/usr/bin/env bash

# takes about 4m 

get_adj_matrix() {
    local -ri j="${1}"; shift
    local -ri i="${1}"; shift

    for ((x=-1; x < 2; x++));do
	for ((y=-1; y < 2; y++));do
	    new_j="$((j + x))"
	    new_i="$((i + y))"

	    if (( j == new_j && i == new_i ));then
		continue
	    fi

	    echo "${new_j}" "${new_i}"
	    
	done
    done

}

getchar() {
    local -rn _grid="${1}"; shift
    local -r x="${1}"; shift
    local -r y="${1}"; shift

    echo "${grid[${x}]:${y}:1}"
}

is_char_roll() {
    local -r char="${1}"; shift
    [[ "${char}" == '@' ]]
}

is_coord_on_grid() {
    local -rn _grid="${1}"; shift
    local -ri j="${1}"; shift
    local -ri i="${1}"; shift
    (( j >= 0 && j < "${#_grid[0]}" )) && (( i >= 0 && i < "${#_grid[@]}" ))
}

main() {
    # args
    local -r input_file="${1}"; shift
    
    local -a grid
    local -i I=0
    local -i J=0
    local -i adj_rolls_counter=0
    local -i result=0

    readarray -t grid < "${input_file}"

    I=$(( ${#grid[0]} ))
    J=$(( ${#grid[@]} ))
    
    for ((j=0; j < "${J}"; j++));do
	echo "LINE: ${j}"
	for ((i=0; i < "${I}"; i++));do
	    is_char_roll $(getchar grid "$j" "$i") || continue
	    adj_rolls_counter=0
	    while IFS=' ' read -r cj ci;do
		is_coord_on_grid grid "$cj" "$ci" || continue
		is_char_roll $(getchar grid "$cj" "$ci") || continue
		((adj_rolls_counter++))
	    done < <(get_adj_matrix "${j}" "${i}")
	    (( adj_rolls_counter < 4 )) && ((result++))
	done
    done

    echo "${result}"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "${@}"
