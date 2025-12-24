#!/usr/bin/env bash

node_combinations()
{
    local -rn _boxes="${1}"; shift

    for ((i=0; i < "${#_boxes[@]}"; i++));do
	for ((j=$((i + 1)); j < "${#_boxes[@]}"; j++));do
	    echo "${_boxes[$i]}" "${_boxes[$j]}"
	done
    done 
}

find_parent ()
{
    local -r node="${1}"; shift

    local -r curr_parent="${parent[${node}]}"

    if [[  "${curr_parent}" == "${node}" ]];then
	echo "${node}"
	return
    fi

    echo "$(find_parent ${curr_parent})"
}

set_union ()
{
    local -r left="${1}"; shift
    local -r right="${1}"; shift

    local -r left_parent="$( find_parent "${left}" )"
    local -r right_parent="$( find_parent "${right}" )"

    if [[ "${left_parent}" == "${right_parent}" ]];then
	return
    fi

    parent["${right_parent}"]="${left_parent}"
}

main ()
{
    # args
    local -r input_file="${1}"; shift

    mapfile -t < "${input_file}"
    declare -Ag parent

    local -ri COUNT_FIRST_N="${COUNT_FIRST_N?'Need to set COUNT_FIRST_N=INT as an env var.'}"

    for node in "${MAPFILE[@]}";do
	parent[${node}]=${node}
    done
    
    while IFS=' ' read -r lx ly lz rx ry rz;do
	set_union "${lx},${ly},${lz}" "${rx},${ry},${rz}"
    done < <(node_combinations MAPFILE \
			    | tr ',' ' ' \
			    | awk '{ print $0, ( ( $1 - $4  )^2 + ( $2 - $5 )^2 + ( $3 - $6 )^2  )^(1/2) }' \
			    | sort -t ' ' -n -k7,7 \
			    | head -n "${COUNT_FIRST_N}" \
			    | cut -f -6 -d ' ')

    printf '%s\n' "${!parent[@]}" \
	| while IFS='' read -r node;do find_parent "${node}"; done \
	| sort \
	| uniq -c \
	| sort -nr \
	| head -n 3 \
	| awk -v p=1 '{ p *= $1 } END {print p}'
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "${@}"
