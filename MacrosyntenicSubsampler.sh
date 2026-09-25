#!/usr/bin/env bash

# Usage:
# ./MacrosyntenicSubsampler.sh <input_file> <output_prefix> [subsample_size]

input_file="$1"
output_prefix="$2"

# Default subsample size = half the number of pairs in the original table, rounded up, but here is where the argument value subsample size is also set.
if [ -n "$3" ]; then
    subsample_size="$3"
else
    total_lines=$(wc -l < "$input_file")
    subsample_size=$(( (total_lines + 1) / 2 ))
fi

# Form each subsample folder, then run the MacrosyntR script on each subsample. Move the results to the subsample folder.
for i in $(seq -w 1 100);
do
    seed=$(sed -n "${i}p" seeds.txt)

    mkdir "Subsample_$i"

    shuf --random-source=<(yes "$seed") \
         -n "$subsample_size" \
         "$input_file" \
         > "${output_prefix}${i}.tsv"

    Rscript TestSignificance.r "${output_prefix}${i}.tsv"

    mv Rplots.pdf Test_Table.tsv "${output_prefix}${i}.tsv" "Subsample_$i"
done

# Create a list of Unique pairs recovered across all subsamples.

cat Subsample*/Test_Table.tsv | \
awk 'BEGIN { OFS="\t" }{print $2,$3}' | \
sort -u > Unique.txt

# Test that Unique.txt works
Uline=1
while read i;
do
    test $Uline -eq 1 && ((Uline=Uline+1)) && continue
    echo "$i"
    grep "$i" */Test_Table.tsv | wc -l
done < Unique.txt > Unique.debug.txt

# Count appearances of each unique pair across the 100 subsamples
UAline=1
while read i; do
  test $UAline -eq 1 && ((UAline=UAline+1)) && continue
  count=$(grep "$i" */Test_Table.tsv | wc -l)
  printf "%s\t%s\n" "${i//\"/}" "$count"
done < Unique.txt > Unique.Appearances.tsv

# Count number of times each unique pair is significant across the 100 subsamples
USline=1
while read i; do
  test $USline -eq 1 && ((USline=USline+1)) && continue
  count=$(grep "$i.*yes" */Test_Table.tsv | wc -l)
  printf "%s\t%s\n" "${i//\"/}" "$count"
done < Unique.txt > Unique.Significant.tsv

