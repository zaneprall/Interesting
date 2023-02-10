#!/bin/bash

function parse_csv() {
    # Get the first line of the csv file, which is the header line
    header=$(head -1 "$1")

    # Replace all commas in the header line with underscores
    header=${header//,/_}

    # Create an array from the header line
    headers=($header)

    # Get the number of columns in the csv file
    num_columns=${#headers[@]}

    # Generate the SQL CREATE TABLE statement
    create_table_statement="CREATE TABLE data_table (id SERIAL PRIMARY KEY, ${headers[0]} VARCHAR(255)"
    for ((i=1; i<num_columns; i++)); do
        create_table_statement="$create_table_statement, ${headers[i]} VARCHAR(255)"
    done
    create_table_statement="$create_table_statement);"

    # Generate the SQL INSERT statements
    insert_statements=""
    while IFS=, read -r line; do
        insert_statements="$insert_statements\nINSERT INTO data_table (${header}) VALUES ('$line');"
    done < "$1"

    # Output the SQL statements to a file
    current_date_time=$(date +"%Y-%m-%d_%H-%M-%S")
    output_file="$current_date_time.sql"
    echo -e "$create_table_statement\n$insert_statements" > "$output_file"
    echo "SQL statements written to $output_file"
}

echo "Enter the path of the .csv file: "
read file_path

parse_csv "$file_path"
