#!/bin/bash

# Comprehensive InfoSec Toolkit
# Features: Port Scanning, Server Headers, DNS Lookup, Network Info, System Monitoring, File Encryption/Decryption, Log Analysis

# Port Scanning Function
function port_scan() {
    echo "Enter the target IP address for port scanning:"
    read target_ip
    echo "Scanning common ports on $target_ip..."
    for port in 22 80 443; do
        (echo > /dev/tcp/$target_ip/$port) >/dev/null 2>&1 && echo "Port $port is open" &
    done
    wait
}

# Server Header Check Function
function server_headers() {
    echo "Enter the URL to check server headers (e.g., http://example.com):"
    read url
    echo "Server headers for $url:"
    curl -I $url
}

# DNS Lookup Function
function dns_lookup() {
    echo "Enter the domain for DNS lookup:"
    read domain
    echo "DNS records for $domain:"
    dig +short $domain ANY
}

# Network Information Function
function network_info() {
    echo "Gathering network information..."
    echo "IP Address:"
    ip addr show | grep 'inet ' | awk '{print $2}'
    echo "Routing Table:"
    netstat -rn
    echo "Network Connections:"
    netstat -tulnp
}

# System Monitoring Function
function system_monitoring() {
    echo "Starting system monitoring..."
    while true; do
        echo "-----"
        echo "Memory Usage:"
        free -h
        echo "Disk Usage:"
        df -h
        echo "CPU Load:"
        top -bn1 | grep load
        sleep 30 # Adjust the sleep duration as needed
    done
}

# File Encryption Function
# Encrypts a specified file using OpenSSL with AES-256 encryption
function file_encryption() {
    echo "Enter filename to encrypt:"
    read filename
    echo "Encrypting $filename..."
    openssl enc -aes-256-cbc -salt -in $filename -out $filename.enc
    echo "File encrypted: $filename.enc"
}

# File Decryption Function
# Decrypts a specified file that was encrypted using the above method
function file_decryption() {
    echo "Enter filename to decrypt:"
    read filename
    echo "Decrypting $filename..."
    openssl enc -aes-256-cbc -d -in $filename -out $filename.dec
    echo "File decrypted: $filename.dec"
}

# Log Analysis Function
# Searches for a specific pattern in a given log file
function log_analysis() {
    echo "Enter the log file path:"
    read log_file
    echo "Enter the pattern to search for:"
    read pattern
    echo "Log entries matching pattern:"
    grep "$pattern" $log_file
}

# Main Menu Function
# Reprints the menu options each time before asking for a selection
function main_menu() {
    while true; do
        echo "Please select an option:"
        echo "1) Port Scan"
        echo "2) Server Headers"
        echo "3) DNS Lookup"
        echo "4) Network Info"
        echo "5) System Monitoring"
        echo "6) File Encryption"
        echo "7) File Decryption"
        echo "8) Log Analysis"
        echo "9) Quit"
        read -p "Enter option: " opt

        case $opt in
            1)
                port_scan
                ;;
            2)
                server_headers
                ;;
            3)
                dns_lookup
                ;;
            4)
                network_info
                ;;
            5)
                system_monitoring
                ;;
            6)
                file_encryption
                ;;
            7)
                file_decryption
                ;;
            8)
                log_analysis
                ;;
            9)
                break
                ;;
            *)
                echo "Invalid option $opt"
                ;;
        esac
    done
}

echo "Comprehensive InfoSec Toolkit"
main_menu
