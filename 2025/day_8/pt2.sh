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

declare -ig successful_union

set_union ()
{
    local -r left="${1}"; shift
    local -r right="${1}"; shift

    local -r left_parent="$( find_parent "${left}" )"
    local -r right_parent="$( find_parent "${right}" )"

    if [[ "${left_parent}" == "${right_parent}" ]];then
	return
    fi

    ((successful_union++))
    parent["${right_parent}"]="${left_parent}"
}

is_all_connected()
{
    local circuit_name="NONE"

    for node in "${!parent[@]}";do
	curr_parent="$(find_parent "${node}")"
	if [[ "$circuit_name"  == "NONE" ]];then
	    circuit_name="${curr_parent}"
	    continue
	fi

	if [[ "${circuit_name}" != "${curr_parent}" ]];then
	    return 1
	fi
	
    done
}

main ()
{
    # args
    local -r input_file="${1}"; shift

    mapfile -t < "${input_file}"
    declare -Ag parent

    for node in "${MAPFILE[@]}";do
	parent[${node}]=${node}
    done
    
    while IFS=' ' read -r lx ly lz rx ry rz;do
	set_union "${lx},${ly},${lz}" "${rx},${ry},${rz}"

	if (( successful_union == ("${#parent[@]}" - 1) ));then
	    echo $((lx * rx))
	    break
	fi

    done < <(node_combinations MAPFILE \
			    | tr ',' ' ' \
			    | awk '{ print $0, ( ( $1 - $4  )^2 + ( $2 - $5 )^2 + ( $3 - $6 )^2  )^(1/2) }' \
			    | sort -t ' ' -n -k7,7 \
			    | cut -f -6 -d ' ')

}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "${@}"
