#!/bin/bash

# Generate a self-signed certificate for code-server
#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/selfsigned.key -out /tmp/selfsigned.crt -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com"

/usr/sbin/sshd -D & 
code-server --bind-addr 0.0.0.0:8080 --cert /data/cert/fullchain.pem --cert-key /data/cert/privkey.pem &
wait