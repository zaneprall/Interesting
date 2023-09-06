#!/bin/bash

# Define variables for configuration
outfile="captured_document"  # Filename to save the captured document
port=631                     # Port number to listen on
block_size="1M"              # Block size used by 'dd' for capturing

# Function to handle POST request
handle_post() {
  echo "Capturing document to $outfile..."

  # Loop to read and discard HTTP headers until an empty line is found
  while IFS= read -r header; do
    [ "$header" == $'\r' ] && break
  done

  # Capture the binary content of the POST request until EOF or client disconnects
  dd of="$outfile" bs="$block_size" 2>/dev/null
}

# Send initial server information
nc -l $port <<EOF_INIT
HTTP/1.1 200 OK
Server: CUPS/2.2.7
Date: $(date -u +"%a, %d %b %Y %H:%M:%S GMT")
Content-Type: text/plain

EPSON L805
EPSON Inkjet Printer
EPSON
L805

direct socket "" ""

EOF_INIT

# Indicate readiness to accept CUPS connections
echo "Waiting for CUPS connection..."
nc -l $port <<EOF_REQUEST
HTTP/1.1 200 OK
Server: CUPS/2.2.7
Date: $(date -u +"%a, %d %b %Y %H:%M:%S GMT")
Content-Type: text/plain

EPSON L805
Ready
EPSON
L805

EOF_REQUEST

# Main loop to handle incoming requests
while :; do
  { read -r request_line; } <&3
  echo "Received request: $request_line"

  # Handle POST requests for printing
  if [[ "$request_line" =~ "POST /printers/EPSON_L805" ]]; then
    handle_post <&3
  # Handle GET request for printer status
  elif [[ "$request_line" =~ "GET /printers/EPSON_L805" ]]; then
    echo -ne "HTTP/1.1 200 OK\r\nServer: CUPS/2.2.7\r\nDate: $(date -u +"%a, %d %b %Y %H:%M:%S GMT")\r\nContent-Type: text/plain\r\n\r\nEPSON L805\nReady\nEPSON\nL805\n" <&3
  # Handle GET request for job status
  elif [[ "$request_line" =~ "GET /jobs" ]]; then
    echo -ne "HTTP/1.1 200 OK\r\nServer: CUPS/2.2.7\r\nDate: $(date -u +"%a, %d %b %Y %H:%M:%S GMT")\r\nContent-Type: text/plain\r\n\r\nNo jobs\n" <&3
  # Handle other requests as Bad Request
  else
    echo -ne "HTTP/1.1 400 Bad Request\r\nServer: CUPS/2.2.7\r\nDate: $(date -u +"%a, %d %b %Y %H:%M:%S GMT")\r\nContent-Type: text/plain\r\n\r\nBad Request\n" <&3
  fi
done 3< <(nc -l -p $port)
