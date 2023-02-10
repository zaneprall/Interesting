#!/bin/bash


nc -l 631 <<EOF_INIT
HTTP/1.1 200 OK
Server: CUPS/2.2.7
Date: Mon, 04 Feb 2023 11:11:11 GMT
Content-Type: text/plain

EPSON L805
EPSON Inkjet Printer
EPSON
L805

direct socket "" ""

EOF_INIT


echo "Waiting for CUPS connection..."
nc -l 631 <<EOF_REQUEST
HTTP/1.1 200 OK
Server: CUPS/2.2.7
Date: Mon, 04 Feb 2023 11:11:11 GMT
Content-Type: text/plain

EPSON L805
Ready
EPSON
L805

EOF_REQUEST


while true; do
  
  read -r line

  
  echo "Received request: $line"

 
  if [[ "$line" == "GET /printers/EPSON_L805" ]]; then
    echo "HTTP/1.1 200 OK
Server: CUPS/2.2.7
Date: Mon, 04 Feb 2023 11:11:11 GMT
Content-Type: text/plain

EPSON L805
Ready
EPSON
L805
"
  elif [[ "$line" == "GET /jobs" ]]; then
    echo "HTTP/1.1 200 OK
Server: CUPS/2.2.7
Date: Mon, 04 Feb 2023 11:11:11 GMT
Content-Type: text/plain

No jobs
"
  else
    echo "HTTP/1.1 400 Bad Request
Server: CUPS/2.2.7
Date: Mon, 04 Feb 2023 11:11:11 GMT
Content-Type: text/plain

Bad Request
"
  fi
done
