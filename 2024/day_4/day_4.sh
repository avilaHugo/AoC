rot() (
    i_j=${1}; f=${2}
    readarray -t a < $f; declare -A new
    for ((i=0; i<=$((${#a[@]}-1)); i++));do
        for ((j=0; j<=$((${#a[0]}-1)); j++));do
           eval 'new['"${i_j}"']+="${a[$i]:$j:1}"'
        done
    done
    printf '%s\n' "${new[@]}"
)

( # PT 1
    cat $1 | tee >(rev)                   # <->
    rot '$j' $1 | tee >(rev)              # v|^
    rot '$((i-j))' $1 | tee >(rev)        # ./°
    rot '$((i-j))' <(rev $1) | tee >(rev) # °\.
) | grep -o XMAS | wc -l
