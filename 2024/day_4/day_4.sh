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
seeds() {
    (while read f; do grep --label=$((c++)) -Honb A <<< $f ; done < $1) \
        | tr ':' ' ' | cut -d' ' -f1,3
}
pos() { echo '${a[$((i'"${1}"'))]:$((j'"${2}"')):1}'; }

# Usage: $ this.sh input.txt
( # PT 1
    cat $1 | tee >(rev)                   # <->
    rot '$j' $1 | tee >(rev)              # v|^
    rot '$((i-j))' $1 | tee >(rev)        # ./°
    rot '$((i-j))' <(rev $1) | tee >(rev) # °\.
) | grep -o XMAS | wc -l

( # PT 2
    readarray -t a < $1
    while read -r i j ;do
        eval echo "$(pos -1 -1)A$(pos +1 +1)@$(pos +1 -1)A$(pos -1 +1)" 
    done < <(seeds $1) 
) | grep -Pc '(SAM|MAS)@(SAM|MAS)'
