#!/usr/bin/env bash

set -oeu pipefail

main()(
    input_file=$1
    result=0
    
    while read -r f;do
        numbers=()
        
        for ((i=0; i<"${#f}"; i++));do
            [[ "${f:${i}:1}" == [[:digit:]] ]] && numbers+=( "${f:${i}:1}" )
        done

        ((result+="${numbers[0]}${numbers[-1]}"))

    done < "${input_file}"
    
    echo "${result}"

)

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && {
    main "${@}"
    exit 0
}

exit 1
