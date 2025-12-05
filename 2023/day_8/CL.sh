#!/usr/bin/env bash

sed -r '
    /^$/d;
    s|[^[:alnum:][:space:]]||g;
    s|([[:space:]])+|\1|g' \
    | awk '
        function part_1(){
            CURRENT_NODE = "AAA"

            while (CURRENT_NODE != "ZZZ") {

                if (next_index > directions_len) { next_index=1 }

                CURRENT_NODE = nodes[CURRENT_NODE][substr(DIRECTIONS, next_index, 1)]

                next_index++
                c++
            }
            return c
        }

        function part_2() {
            # Get nodes ending with A
            for (node in nodes) { if (node ~ /A$/) { current_nodes[node]=0 } }

            while (any_non_Z(current_nodes) == 1) {

                if (next_index > directions_len) { next_index=1 }

                for (node in current_nodes) {
                    if (node ~ /Z$/) { continue }

                    next_node = nodes[node][substr(DIRECTIONS, next_index, 1)]
                    current_nodes[next_node] = current_nodes[node] + 1
                    delete current_nodes[node]
                }

                next_index++
            }

            lcm = current_nodes[node]
            delete current_nodes[node]

            for (node in current_nodes) {
                lcm = get_lcm(lcm, current_nodes[node])
            }

            return lcm

        }

        function any_non_Z(arr_name) {
            for (node in arr_name) { if (node !~ /Z$/) { return 1 } }
            return 0
        }

        function get_gcd(a, b) {

            if ( a == b ) { return a }

            max = (a > b)? a : b
            min = (a < b)? a : b

            return get_gcd((max - min), min)
        
        }

        function get_lcm(a, b) {
            return ( (a * b)/get_gcd(a, b) )
        }

        # BUILD TREE
        NR == 1 {
            DIRECTIONS=$0;
            directions_len=length(DIRECTIONS)
            next_index=1
            next;
        }

        {
            nodes[$1]["L"] = $2
            nodes[$1]["R"] = $3
        }

        END {
            # print part_1()
            print part_2()
        }
    '






