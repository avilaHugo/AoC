#!/usr/bin/env bash
pt1(){ grep -Po 'mul\(\d{1,3},\d{1,3}\)' "${1}"; }
pt2(){
    grep -Po '(do(n'\''t)?\(\))|mul\(\d{1,3},\d{1,3}\)' "${1}" \
        | awk -v F=1 '/^don/ {F=0; next} /do\(/ {F=1; next} F==1'
}
compute() { sed 's/,/*/;s/mul//;s:^: + :' | xargs echo 0 | bc; }
pt1 "${1?'Input file.'}" | compute
pt2 "${1?'Input file.'}" | compute
