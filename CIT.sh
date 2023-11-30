#!/bin/bash

# Comprehensive InfoSec Toolkit
# Features: Port Scanning, Server Headers, DNS Lookup, Network Info, System Monitoring, File Encryption/Decryption, Log Analysis

# Port Scanning Function
function port_scan() {
    echo "Enter the target IP address for port scanning:"
    read target_ip

    echo "Enter the starting port number:"
    read start_port

    echo "Enter the ending port number:"
    read end_port

    echo "Scanning ports from $start_port to $end_port on $target_ip..."

    # Function to check individual port with timeout
    function check_port {
        (echo > /dev/tcp/$target_ip/$1) >/dev/null 2>&1 && echo "Port $1 is open"
    }

    # Loop over the specified port range and initiate scans in parallel
    for ((port=$start_port; port<=$end_port; port++)); do
        check_port $port &
        sleep 0.1 # Prevent too many simultaneous connections
    done

    wait # Wait for all background processes to finish
    echo "Port scanning completed."
}

# Server Header Check Function
function server_headers() {
    echo "Enter the URL to check server headers (e.g., http://example.com):"
    read url

    # URL Validation
    if ! [[ $url =~ ^http[s]?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$ ]]; then
        echo "Invalid URL format. Please use 'http://' or 'https://' followed by the domain name."
        return
    fi

    # Timeout for curl
    echo "Server headers for $url:"
    curl -I --connect-timeout 10 $url || echo "Failed to retrieve headers. The server might be down or the URL is incorrect."
}

# DNS Lookup Function
function dns_lookup() {
    echo "Enter the domain for DNS lookup:"
    read domain

    # Domain name validation
    if ! [[ $domain =~ ^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.?)+[a-zA-Z]{2,}$ ]]; then
        echo "Invalid domain format. Please enter a valid domain."
        return
    fi

    # Allow user to specify DNS record type
    echo "Enter the DNS record type (A, AAAA, MX, TXT, etc. or 'ANY' for all types):"
    read record_type

    # Validate record type
    if ! [[ $record_type =~ ^(A|AAAA|MX|TXT|CNAME|NS|SOA|SRV|ANY)$ ]]; then
        echo "Invalid DNS record type. Please enter a valid type like A, AAAA, MX, etc."
        return
    fi

    echo "DNS records for $domain of type $record_type:"
    dig +noall +answer $domain $record_type || echo "Failed to retrieve DNS records. Please check the domain and record type."
}

# Network Information Function
function network_info() {
    while true; do
        echo "Network Information Options:"
        echo "1) IP Addresses"
        echo "2) Routing Table"
        echo "3) Network Connections"
        echo "4) All Information"
        echo "5) Return to Main Menu"
        read -p "Select the information to display (1-5): " choice

        case $choice in
            1)
                echo "IP Addresses:"
                ip addr show | awk '/inet / {print $2}'
                ;;
            2)
                echo "Routing Table:"
                netstat -rn
                ;;
            3)
                echo "Network Connections:"
                netstat -tulnp
                ;;
            4)
                echo "IP Addresses:"
                ip addr show | awk '/inet / {print $2}'
                echo "Routing Table:"
                netstat -rn
                echo "Network Connections:"
                netstat -tulnp
                ;;
            5)
                break
                ;;
            *)
                echo "Invalid option. Please select a number between 1 and 5."
                ;;
        esac
    done
}
# System Monitoring Function
function system_monitoring() {
    echo "Enter the refresh rate in seconds (e.g., 5 for 5 seconds):"
    read refresh_rate

    # Validating the refresh rate input
    if ! [[ $refresh_rate =~ ^[0-9]+$ ]] || [ $refresh_rate -le 0 ]; then
        echo "Invalid input. Please enter a positive number for the refresh rate."
        return
    fi

    echo "Starting system monitoring... (press Ctrl+C to stop)"
    trap 'tput cnorm; clear; return' SIGINT
    tput civis # Hide cursor

    while true; do
        clear
        echo "----- System Monitoring (Refresh Rate: $refresh_rate seconds) -----"
        date "+%Y-%m-%d %H:%M:%S"

        echo "Memory Usage:"
        free -h

        echo "Disk Usage:"
        df -h

        echo "CPU Load:"
        top -bn1 | grep load

        echo "Top CPU-consuming processes:"
        ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head

        sleep $refresh_rate
    done
}



# File Encryption Function
# Encrypts a specified file using OpenSSL with AES-256 encryption
function file_encryption() {
    echo "Enter filename to encrypt:"
    read filename

    # Check if the file exists
    if [ ! -f "$filename" ]; then
        echo "File not found: $filename"
        return
    fi

    # Allow user to specify the output filename
    echo "Enter the output filename for the encrypted file:"
    read output_filename

    # Get encryption password and confirmation
    echo "Enter the password for encryption:"
    read -s password
    echo "Confirm the password:"
    read -s password_confirm

    # Check if passwords match
    if [ "$password" != "$password_confirm" ]; then
        echo "Passwords do not match."
        return
    fi

    # Perform encryption
    if openssl enc -aes-256-cbc -salt -in "$filename" -out "$output_filename" -k "$password"; then
        echo "File encrypted successfully: $output_filename"
    else
        echo "Failed to encrypt the file."
    fi
}


# File Decryption Function
# Decrypts a specified file that was encrypted using the above method
function file_decryption() {
    echo "Enter the filename to decrypt:"
    read encrypted_filename

    # Check if the encrypted file exists
    if [ ! -f "$encrypted_filename" ]; then
        echo "Encrypted file not found: $encrypted_filename"
        return
    fi

    # Allow user to specify the output filename for the decrypted file
    echo "Enter the output filename for the decrypted file:"
    read output_filename

    # Get decryption password
    echo "Enter the password for decryption:"
    read -s password

    # Perform decryption
    if openssl enc -aes-256-cbc -d -in "$encrypted_filename" -out "$output_filename" -k "$password"; then
        echo "File decrypted successfully: $output_filename"
    else
        echo "Failed to decrypt the file. Please check the password and file integrity."
    fi
}


# Log Analysis Function
# Searches for a specific pattern in a given log file
function log_analysis() {
    echo "Enter the log file path:"
    read log_file

    # Check if the log file exists
    if [ ! -f "$log_file" ]; then
        echo "Log file not found: $log_file"
        return
    fi

    echo "Enter the pattern to search for (regex allowed):"
    read pattern

    # Ask user if they want a case-insensitive search
    echo "Perform a case-insensitive search? (yes/no):"
    read case_insensitive

    # Ask user for the number of contextual lines to display
    echo "Enter the number of lines to display around each match (context):"
    read context_lines

    # Validate the context_lines input
    if ! [[ $context_lines =~ ^[0-9]+$ ]]; then
        echo "Invalid input. Please enter a number for the context lines."
        return
    fi

    # Build the grep command
    grep_command="grep -n"
    if [[ $case_insensitive == "yes" ]]; then
        grep_command="$grep_command -i"
    fi
    if [[ $context_lines -gt 0 ]]; then
        grep_command="$grep_command -C $context_lines"
    fi
    grep_command="$grep_command --color=always '$pattern' $log_file"

    # Execute the grep command
    echo "Searching for pattern in $log_file..."
    eval $grep_command || echo "No matches found or error in searching."
}

# Main Menu Function
# Reprints the menu options each time before asking for a selection

function display_help() {
    echo "Help Information:"
    echo "1) Port Scan - Scan a range of ports on a target IP."
    echo "2) Server Headers - Retrieve HTTP headers from a specified URL."
    echo "3) DNS Lookup - Perform DNS lookups and query DNS records."
    echo "4) Network Info - Display network-related information like IP addresses, routing table, etc."
    echo "5) System Monitoring - Monitor system resources such as memory, disk, and CPU usage."
    echo "6) File Encryption - Encrypt files using AES-256 encryption."
    echo "7) File Decryption - Decrypt files encrypted by this script."
    echo "8) Log Analysis - Search and analyze patterns in log files."
    echo "9) Help - Display this help information."
    echo "10) Exit - Exit the script."
    echo "Choose an option from the main menu to perform the corresponding action."
}

function main_menu() {
    while true; do
        clear
        echo "Main Menu - InfoSec Toolkit"
        echo "1) Port Scan"
        echo "2) Server Headers"
        echo "3) DNS Lookup"
        echo "4) Network Info"
        echo "5) System Monitoring"
        echo "6) File Encryption"
        echo "7) File Decryption"
        echo "8) Log Analysis"
        echo "9) Help"
        echo "10) Exit"
        read -p "Enter option (1-10): " opt

        case $opt in
            1) port_scan ;;
            2) server_headers ;;
            3) dns_lookup ;;
            4) network_info ;;
            5) system_monitoring ;;
            6) file_encryption ;;
            7) file_decryption ;;
            8) log_analysis ;;
            9) display_help ;;
            10)
                read -p "Are you sure you want to exit? (yes/no): " confirm_exit
                if [[ $confirm_exit == "yes" ]]; then
                    clear
                    break
                fi
                ;;
            *)
                echo "Invalid option. Please select a number between 1 and 10."
                ;;
        esac
        echo "Press any key to return to the main menu..."
        read -n 1
    done
}

echo "Welcome to the Comprehensive InfoSec Toolkit"
main_menu
