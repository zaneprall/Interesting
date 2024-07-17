#!/bin/bash

# Usage: ./script.sh [number_of_tiers]
# Example: './script.sh 8'

# default to 3 if not specified.
tiers=${1:-3}

# Set up base dir
base_dir="working"
mkdir -p "$base_dir"
rm -f "$base_dir"/*

current_zip="$base_dir/initial_files.zip"

# Step 1: Generate 10 random files
mkdir -p "$base_dir/files"
for i in {1..10}; do
    dd if=/dev/random of="$base_dir/files/file_$i" bs=1024 count=1024 2>/dev/null
done
zip -j "$current_zip" "$base_dir/files"/*

# Clean up files post-zip
rm -r "$base_dir/files"

# Steps 2 to N: Create zips within zips
for (( i=1; i<tiers; i++ )); do
    next_dir="$base_dir/temp_$i"
    mkdir -p "$next_dir"

    # Clone the previous zip 10 times into the next dirs
    for j in {1..10}; do
        cp "$current_zip" "$next_dir/zip_copy_$j.zip"
    done

    # zips all the way down.
    new_zip="$base_dir/level_${i}_zip.zip"
    zip "$new_zip" "$next_dir"/*.zip

    # more zips
    current_zip="$new_zip"
    rm -r "$next_dir"
done

# Final zip
final_zip="final_nested_zip.zip"
mv "$current_zip" "$final_zip"
echo "All done. see: $final_zip"
