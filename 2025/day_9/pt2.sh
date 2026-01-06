#!/usr/bin/env bash

main ()
{
    # args
    local -r input_file="${1}"; shift

    local -i result=0

    mapfile -t < "${input_file}"

    declare -A X_LOOKUP
    declare -A Y_LOOKUP

    declare -a cycle=(${MAPFILE[-1]} ${MAPFILE[@]} ${MAPFILE[0]})
    for ((i=1; i < $(("${#cycle[@]}" - 1 )); i++));do
	IFS=',' read -r px py <<< "${cycle[$((i - 1))]}"
	IFS=',' read -r x  y  <<< "${cycle[${i}]}"
	IFS=',' read -r nx ny <<< "${cycle[$((i + 1))]}"

	# Hori
	X_LOOKUP["${y}"]="${X_LOOKUP[${y}]} "$( (( x < px )) && echo "${x},${px}" || echo "${px},${x}" )
	X_LOOKUP["${y}"]="${X_LOOKUP[${y}]} "$( (( x < nx )) && echo "${x},${nx}" || echo "${nx},${x}" )

	# verti
	Y_LOOKUP["${x}"]="${X_LOOKUP[${x}]} "$( (( y < py )) && echo "${y},${py}" || echo "${py},${y}" )
	Y_LOOKUP["${x}"]="${X_LOOKUP[${x}]} "$( (( y < ny )) && echo "${y},${ny}" || echo "${ny},${y}" )
    done

    for i in "${!X_LOOKUP[@]}";do
	X_LOOKUP["${i}"]=$( declare -A temp; for j in ${X_LOOKUP[${i}]};do temp[${j}]=0; done; echo "${!temp[@]}" )
    done

    for i in "${!Y_LOOKUP[@]}";do
	Y_LOOKUP["${i}"]=$( declare -A temp; for j in ${Y_LOOKUP[${i}]};do temp[${j}]=0; done; echo "${!temp[@]}" )
    done

    for ((i=0; i < "${#MAPFILE[@]}"; i++));do
        for ((j=$((i+1)); j < "${#MAPFILE[@]}"; j++));do
	    intersecs=0
            IFS=',' read -r lx ly <<< "${MAPFILE[${i}]}"
            IFS=',' read -r rx ry <<< "${MAPFILE[${j}]}"

	    if (( lx <= rx ));then
	    fi

	    if (( rx <= lx ));then
	    fi

            dx="$(( d=(lx - rx), abs=( d < 1 ? d * -1 : d ), d + 1))"
            dy="$(( d=(ly - ry), abs=( d < 1 ? d * -1 : d ), d + 1))"
            result=$(( a=(dx*dy), a > result ? a : result ))
        done
    done
    echo "${result}"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "${@}"
