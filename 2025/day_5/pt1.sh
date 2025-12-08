
#!/usr/bin/env bash


main() {
    # args
    local -r input_file="${1}"; shift

    local -r exp=$(cat "${input_file}" \
        | grep -- - \
        | perl -pe 's:(\d+)-(\d+):(( \1 <= X && X <= \2 )) || :;s:\n::'  \
        | cat - <(echo) \
        | sed 's: || $::' )

    echo ${exp}
    grep -P '^\d+$' "$input_file" \
        | while OFS='' read -r X;do
            eval "( ${exp//X/${X}} ) && echo $X"
         done \
        | wc -l 
          
    
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "${@}"
