#!/usr/bin/env bash

# USAGE: this.sh < input.txt

# This is the solution for part 2. For part 1, just
# convert the input like this:
# $ sed -r '1s/([[:digit:]]+)/\1 1/g' sample_1.txt > converted_input.txt
# $ solution.sh < converted_input.txt

# WARNING !!! This script will create and delete .temp files
#          at the current dir. If you have some files
#          that match *.temp they are also going to be deleted.            


# This will format the lines and prefix then with
# an identifier. Files will be created using the
# identifier Ex: seed_ranges.temp, soil-to-blablabla.temp
(
    # Setting up seeds ranges
    head -2 \
        | tr ' ' '\n' \
        | sed '/^[[:digit:]]/!d' \
        | paste -d ' ' -- - - \
        | awk '{print "seed_ranges", $1, ($1 + ( $2 - 1 ))}'

    # Formating map ranges 
    sed '/^$/ s/^$/@/; $a@' \
        | while IFS=$'\n' read -r -d '@' MAP_TITLE MAP_RANGES;do
                while read -r MAP_RANGE;do
                    echo "${MAP_TITLE%[[:space:]]*} ${MAP_RANGE}";
                done <<< "${MAP_RANGES}"
           done \
        | awk '
            {
                f=( $4 - 1 )
                # map_range, dest_start, dest_end, source_start, source_end
                print $1,$2,($2 + f),$3,($3 + f)
            }
        '
) \
    | tee >( awk '!a[$1]++ && !/seed_ranges/ {print $1".temp"}' > file_order.temp  ) \
    | while IFS=' ' read -r FILE_NAME DATA;do
        echo "${DATA}" >> "${FILE_NAME}.temp"
      done

# Reading first ranges 
read -d '' SEED_RANGES < seed_ranges.temp

# Get the correct order of the map files.
read -d '' FILE_ORDER < file_order.temp

# This took a lot of my mental health to write
# i'm still not a 100% sure how it works.

# The ideia is to mutate SEED_RANGES on each
# MAP_FILE.
while read -r MAP_FILE ;do
    read -r -d '' SEED_RANGES < <(

        while read -r SEED_START SEED_END ;do

            overlap_intervals=()

            while read -r DEST_START DEST_END SOURCE_START SOURCE_END;do

                # Check if intervals not overlap
                if ! (( (SEED_START <= SOURCE_END) && (SEED_END >= SOURCE_START) ));then
                    continue
                fi

                # Add intervals that do overlap 
                overlap_intervals+=("${DEST_START} ${DEST_END} ${SOURCE_START} ${SOURCE_END}")

            done < <(sort -n -k3 -t ' ' "${MAP_FILE}")

            # Report seed ranges with no overlap intervals
            if (( ${#overlap_intervals[@]} < 1 ));then
                echo "${SEED_START}" "${SEED_END}"
                continue
            fi
           
            # I think i could do this on the first while loop
            # but i could not figure it out, so i did the chunking
            # logic separated from the overlap check.

            # This will do the map conversions on each overlap range
            while read -r DEST_START DEST_END SOURCE_START SOURCE_END;do
                if (( SEED_START < SOURCE_START ));then
                    echo "${SEED_START} $(( SOURCE_START - 1 ))"
                    SEED_START=$(( SOURCE_START ))
                fi

                l=$(( DEST_START + (SEED_START - SOURCE_START) ))
                L=$(( DEST_START + (SEED_END - SOURCE_START) ))

                if (( SEED_END > SOURCE_END ));then
                    L=$(( DEST_START + (SOURCE_END - SOURCE_START) ))
                fi

                echo "${l}" "${L}"
                SEED_START=$(( SOURCE_END + 1 ))

            done < <(printf '%s\n' "${overlap_intervals[@]}" )
           
            # This will print the ramaing seed range on the right side.
            ((SEED_START <= SEED_END)) && echo "${SEED_START}" "${SEED_END}"

        done <<< "${SEED_RANGES}"
    )
    
done <<< "${FILE_ORDER}"

# Read the last SEED_RANGES and print the 
# lowest range (left part).
printf '%s\n' "${SEED_RANGES[@]}" \
    | sort -n -k1 -t ' ' \
    | head -1 \
    | cut -f 1 -d ' '

rm *.temp
