#!/bin/bash

run_tests()
{
    local ip="$1"
    echo 
    echo "* Running tests"
    echo "[openssl verify]"
    echo | openssl s_client -CAfile rootCA.crt -connect "[$ip]:443" | openssl verify  -CAfile rootCA.crt
    echo "[curl]"
    curl -svo/dev/null --cacert rootCA.crt "https://[$ip]" 2>&1 | grep -i ssl
    echo "[client.js]"
    node client.js "$ip"
}

kill $(pgrep node) || true

IP=$(ip -6 a show | grep -Eo "2001:db8[^/]+")

sed -i "s/IP.2  = ::1/IP.2  = $IP/g" localhost.conf

openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 3650 -out rootCA.crt -subj "/C=US/ST=CA/O=Acme"
openssl req -out localhost.csr -new -newkey rsa:2048 -nodes -keyout localhost.key -subj "/C=US/ST=CA/O=Acme, Inc./CN=localhost" -config localhost.conf
openssl x509 -req -days 3650 -in localhost.csr -out localhost.crt -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -extensions req_ext -extfile localhost.conf

node server.js &

sleep 1
echo | openssl s_client -CAfile rootCA.crt -connect "[$IP]:443" | openssl x509 -text -noout

run_tests "$IP"
echo
echo "* patching request.js"
cd node_modules/request
patch -p1 < ../../request.patch
cd - &> /dev/null
run_tests "$IP"

