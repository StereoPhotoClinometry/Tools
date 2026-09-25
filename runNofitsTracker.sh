#!/bin/sh

# output files
output_file="nofits_tracker.txt"
output_file2="nofits_increased.txt"

newFiles="n"

read -p "Start a new tracker? y/[n] " newFiles

# if newFiles is y, check if file exists, and if so rename it, then proceed
if [ "$newFiles" = "y" ]; then
	echo "Refreshing tracker"
	if [ -f "$output_file" ]; then
		echo "renaming old tracker"
		timestamp=$(date +%Y%m%dT%H%M%S)
		cp $output_file "nofits_tracker"_$timestamp".txt"
		echo "nofits_tracker"_$timestamp".txt"
		rm $output_file
	 fi
 fi
 

# Overwrite diff file every run 
echo -n "" > "$output_file2"

# Current iteration file to process
current_file="eval/evalOut.txt"

# Extract the nofit data for this iteration (landmark, nofit value)
grep "nofit" "$current_file" | awk '{print $1, $3}' | sed 's/.OOT//g; s/.OO//g' > temp_current_file_nofits.txt
# alphabetize
sort temp_current_file_nofits.txt > temp_sorted_current_file_nofits.txt
rm temp_current_file_nofits.txt


# Create a temporary tracker to read from while we append to tracker
touch "$output_file"
cp "$output_file" temp_existing_tracker.txt
> temp_updated_tracker.txt

# Count the number of past runs (columns minus landmark name)
num_columns=$(awk 'NF > max { max = NF } END { print max - 1 }' temp_existing_tracker.txt)

# process each line from the existing tracker
while read -r line; do
    landmark=$(echo "$line" | awk '{print $1}')
    previous_value=$(echo "$line" | awk '{print $NF}')

    match=$(grep "^$landmark " temp_sorted_current_file_nofits.txt)

    # if landmark in tracker is also in evalOut, append the nofits value to tracker
    if [ -n "$match" ]; then
        nofit_value=$(echo "$match" | awk '{print $2}')

        # Write diff if increased
        if [ "$nofit_value" -gt "$previous_value" ]; then
            diff=$(expr "$nofit_value" - "$previous_value")
            echo "$landmark $diff" >> "$output_file2"
        fi

        # Append new value and format aligned line
        new_line=$(echo "$line $nofit_value")
    # if landmark did no get flagged, append 0
    else
        new_line=$(echo "$line 0")
    fi

    # Format the new line with fixed-width columns
    echo "$new_line" | awk '{
        printf "%-15s", $1
        for (i = 2; i <= NF; i++) {
            printf "%5s", $i
        }
        printf "\n"
    }' >> temp_updated_tracker.txt

done < temp_existing_tracker.txt

# Get list of landmarks
cut -d' ' -f1 temp_existing_tracker.txt > existing_landmarks.txt
cut -d' ' -f1 temp_sorted_current_file_nofits.txt > current_landmarks.txt

# add any new landmarks not yet in the tracker
grep -Fvxf existing_landmarks.txt current_landmarks.txt | while read -r new_landmark; do

    nofit_value=$(grep "^$new_landmark " temp_sorted_current_file_nofits.txt | awk '{print $2}')

    # Start with the name, backfill with zeros, then append current value
    printf "%-15s" "$new_landmark" >> temp_updated_tracker.txt
    i=0
    while [ "$i" -lt "$num_columns" ]; do
        printf "%5s" 0 >> temp_updated_tracker.txt
        i=$((i+1))
    done
    printf "%5s\n" "$nofit_value" >> temp_updated_tracker.txt

    # log this to the diff file
    echo "$new_landmark $nofit_value" >> "$output_file2"
done

# Finalize
mv temp_updated_tracker.txt "$output_file"
rm temp_existing_tracker.txt temp_sorted_current_file_nofits.txt existing_landmarks.txt current_landmarks.txt

sort -k2,2nr "$output_file2" -o "$output_file2"

echo "Master Tracker: $output_file"
echo "Diff Tracker: $output_file2"

open "$output_file" 
open "$output_file2" 