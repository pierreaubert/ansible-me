#!/bin/sh

server=$1

openssl genrsa -des3 -out $server.key 2048
openssl req -new -newkey rsa:2048 -nodes -out $server.csr -keyout $server.key -subj '/C=FR/ST=Alpes Maritimes/L=Grasse/O=7pi/CN=7pi.eu'
cp $server.key $server.key.org
openssl rsa -in $server.key.org -out $server.key
openssl x509 -req -days 365 -in $server.csr -signkey $server.key -out $server.crt

mv $server.csr $server.crt $server.key* keys
