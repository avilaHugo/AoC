#!/usr/bin/env bash


main ()
{
    # args
    local -r input_file="${1}"; shift

    local -i result=0

    mapfile -t < "${input_file}"

    for ((i=0; i < "${#MAPFILE[@]}"; i++));do
        for ((j=$((i+1)); j < "${#MAPFILE[@]}"; j++));do
            IFS=',' read -r lx ly <<< "${MAPFILE[${i}]}"
            IFS=',' read -r rx ry <<< "${MAPFILE[${j}]}"
            dx="$(( d=(lx - rx), abs=( d < 1 ? d * -1 : d ), d + 1))"
            dy="$(( d=(ly - ry), abs=( d < 1 ? d * -1 : d ), d + 1))"
            result=$(( a=(dx*dy), a > result ? a : result ))
        done
    done
    echo "${result}"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "${@}"
