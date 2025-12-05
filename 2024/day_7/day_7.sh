a:h() { echo "${1}"; }
a:t() { shift; echo "${@}"; }
apply_op() {
    local a="$2" b="$1"; shift 2 # <= !!! ORDER OP is a=$2 b=$1 
    eval echo "${@}" | tr ' ' '\n'
}
a:map() { local op="${1}"; shift; for i;do ${op} "${i}"; done; } 
a:foldl1(){
    local op="${1}" real="${2}" acc=("${3}"); shift 2
    for i;do readarray -t acc < <(a:map "${op} ${i}" "${acc[@]}" | awk '$0 < '"${real}" | sort -u); done
    printf '%s\n' "${acc[@]}"
}
pt1() { apply_op "${1}" "${2}" '$((a + b))' '$((a * b))'; }
pt2() { apply_op "${1}" "${2}" '$((a + b))' '$((a * b))' '$(((a*(10**${#b})) + b))'; }
run() {
    local op="${1}" fn="${2}" acc=0; shift
    while IFS=':' read -r real_total rest;do
        echo ${rest[@]}
        a:foldl1 "${op}" ${rest[@]} | grep -m1 "${real_total}"
        echo $((c++))
    done < "${fn}" | awk '{a+=$0} END {print "'"${op}"':",a}'
}
# run pt1 ${1?'Input file name ?'}
# run pt2 ${1?'Input file name ?'}

# pt1 1 2
a:foldl1 pt1 156346954 9 8 9 5 7 1 59 6 39 3 637
echo pt1
a:foldl1 pt2 156346954 9 8 9 5 7 1 59 6 39 3 637
echo pt2







