#!/usr/bin/env bash

# awk 'CONDICAO {ACAO}' 

format_game_str() {
    sed 's|:|;|;s|;|\n|g' \
        | awk '/Game/ { match($0, /[[:digit:]]+/, arr); ID=arr[0]; pull=0; next }
              { split( $0, cubes, ","); pull++; for (i in cubes) { print ID, pull, cubes[i] } }' \
        | sed -r 's|\s+|,|g'
}

part_1() {
    awk -F ',' 'BEGIN { arr["green"]=13; arr["red"]=12; arr["blue"]=14;  }
                  $3 > arr[$4] { ip[$1] }
                  { result[$1] }
                  END { for (i in result) { if (i in ip == 0) print i }}
                 '
}

part_2() {
    awk -F ',' 'BEGIN { curr_game=1 }

                  curr_game != $1 {
                    results[l++]=arr["red"] * arr["green"] * arr["blue"]
                    curr_game=$1
                    arr["red"]=0; arr["green"]=0; arr["blue"]=0
                  }

                  $3 > arr[$4] {
                    arr[$4]=$3
                  }
                  END {
                    results[l++]=arr["red"] * arr["green"] * arr["blue"]
                    for (i in results) {print results[i]}
                  }
                  '

}

format_game_str \
    | part_2 \
    | awk '{sum+=$0} END {print sum}'
