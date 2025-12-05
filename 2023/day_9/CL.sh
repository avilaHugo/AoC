#!/usr/bin/env bash

awk '
    function check_all_zeros(arr) {
        for (i in arr) {
            if (arr[i] != 0) {
                return 0
            }
        }
        return 1
    }

    {

        split($0, arr, " ")

        while (1) {
            ++T
            trace_last[T]=arr[length(arr)]
            trace_first[T]=arr[1]

            if ( check_all_zeros(arr) == 1 ) {
                break
            }

            for (i=1; i<length(arr); i++) {
                diff[++l] = arr[i+1] - arr[i]
            }
            delete arr
            l=0

            for (i in diff) {
                arr[i]=diff[i]
            }
            delete diff

        }
        T=0

        new_last = 0
        new_first = 0
        for (i=length(trace_last); i > 0; i--) {
            new_last += trace_last[i] 
            new_first = trace_first[i] - new_first 
        }
        delete trace_last
        delete trace_first

        p1+=new_last
        p2+=new_first
    }

    END {
        print "Part 1:", p1
        print "Part 2:", p2
    }
'
