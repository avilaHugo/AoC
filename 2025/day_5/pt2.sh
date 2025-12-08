
#!/usr/bin/env bash

main() {
    # args
    local -r input_file="${1}"; shift

    mapfile -t arr < <(cat "${input_file}" \
                        | grep -E '^[0-9]+-[0-9]+' \
                        | sed 's:-: :' \
                        | sort -n -k1,1 -k2,2  -t ' ' \
                        | uniq 
                        )


    curr=0
    for ((i=1; i < "${#arr[@]}"; i++));do
        IFS=' ' read -r a A <<< "${arr[${curr}]}"
        IFS=' ' read -r b B <<< "${arr[$i]}"
        echo "loop $((c++)): ${arr[@]@Q}"

        if (( b <= A ));then
            arr["${i}"]="0 0"

            if (( B > A ));then
                arr["${curr}"]="${a} ${B}"
            fi

        else
            ((curr="${i}"))
        fi

    done

    echo "FINAL: ${arr[@]@Q}"

    echo "RESULT:" $(printf '%s\n' "${arr[@]}" \
        | grep -v '^0 0$' \
        | perl -pe 's:^(\d+) (\d+)$: ( (\2 - \1) + 1 ) +  :' \
        | tr -d '\n' \
        | cat - <(echo 0) \
        | bc)


}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "${@}"
