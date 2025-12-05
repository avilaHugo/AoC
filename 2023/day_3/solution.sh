#!/usr/bin/env bash

create_db() {
    local db_name="${1}"

    while read -r line ;do
        grep --label="$((c++))" -H -Pob '[[:digit:]]+|[^[:digit:].]+' <<< "${line}" 
    done \
        | awk -F ':' -v OFS=',' '{print $1,$2,( $2 + length($3) - 1 ), $3, $3 ~ /[[:digit:]]+/? "number" : "symbol" }' \
        | awk -F ',' -v q="'" '
            BEGIN {
                print "CREATE TABLE game (i INT, j1 INT, j2 INT, match TEXT, type TEXT);"
            }
            {
                printf("INSERT INTO game VALUES(%s, %s, %s, %s, %s);\n", $1, $2, $3, q$4q, q$5q)
            }
        ' \
        | sqlite3 "${db_name}" 

}

part_1_query(){
    local db_name="${1}"

    sqlite3 "${db_name}" "SELECT * FROM game WHERE type = 'number'"  \
        | while IFS='|' read -r i j1 j2 _match _type;do
            cat << EOF | sqlite3 "${db_name}" | grep -m1  -q . && echo "${_match}"
            SELECT * FROM game
            WHERE (
                (type = 'symbol') AND
                ( i >= $(( ${i} - 1))  ) AND
                ( i <= $(( ${i} + 1))  ) AND
                ( j1 >= $(( ${j1} - 1))  ) AND
                ( j2 <= $(( ${j2} + 1))  ) 
            );
EOF
        done

}

part_2_query(){
    local db_name="${1}"

    sqlite3 "${db_name}" "SELECT * FROM game WHERE type = 'symbol' AND match = '*'"  \
        | while IFS='|' read -r i j1 j2 _match _type;do
            cat << EOF | sqlite3 "${db_name}" | awk '{ arr[l++]=$0  } END { if (NR == 2) print arr[0]*arr[1]  }'
            SELECT match FROM game
            WHERE (
                (type = 'number') AND
                ( i >= $(( ${i} - 1))  ) AND
                ( i <= $(( ${i} + 1))  ) AND
                (  $(( ${j1} - 1)) <= j2  ) AND
                (  $(( ${j2} + 1)) >= j1 ) 
            );
EOF
        done

}

DB_NAME="./test.db"

[[ -f "${DB_NAME}" ]] && rm "${DB_NAME}" 
create_db "${DB_NAME}"

part_1_query "${DB_NAME}"  \
    | awk '{sum+=$0} END {print sum}'

part_2_query "${DB_NAME}"  \
    | awk '{sum+=$0} END {print sum}'
