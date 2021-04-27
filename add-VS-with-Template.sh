#!/bin/bash
#
#  Login and create VIP
#
#  John D. Allen, Global Solutions Architect - Cloud, A10 Networks
#  April, 2021
#

THUNDER_IP="10.1.1.44"
USERNAME="admin"
PASSWD="a10"

URL="https://${THUNDER_IP}:443/axapi/v3"

ITSHERE=0
if ! command -v jq > /dev/null ; then
  ITSHERE=1
fi

#
# Auth first
T1=$(curl -sk --location --request POST "${URL}/auth" \
--header 'Content-Type: application/json' \
--data-raw "{
    \"credentials\": {
        \"username\": \"${USERNAME}\",
        \"password\": \"${PASSWD}\"
    }
}" | head -3 | tail -1 | tr -d '"')

# Sample output to test with instead of tying up your Thunder device.
#T1=$(echo "{
#    "authresponse": {
#        "signature": "61697b59687aee3e4f1b37a801109e",
#        "description": "the signature should be set in Authorization header for following request."
#    }
#}" | head -3 | tail -1 | tr -d '"')

#
# Pull out Auth Signature Token
T2=${T1::-1}
T3=$(echo $T2 | cut -f2 -d ':')
AUTH="A10 ${T3}"

echo $AUTH

#
# Add SLB Virtual-Server with a Template
OUT=$(curl -sk --location --request POST "${URL}/slb/virtual-server" \
--header 'Content-Type: application/json' \
--header "Authorization: ${AUTH}" \
--data-raw '{
  "virtual-server": {
        "name": "nginx-vip",
        "ip-address": "44.147.45.44",
        "template-virtual-server": "bw-control"
  }
}')

if [ $ITSHERE == 0 ]; then
  echo $OUT | jq .
else
  echo $OUT
fi

#
# Be kind to your Thunder and terminate the API session
OUT=$(curl -sk --location --request GET "${URL}/logoff" \
--header 'Content-Type: application/json' \
--header "Authorization: ${AUTH}")

if [ $ITSHERE == 0 ]; then
  echo $OUT | jq .
else
  echo $OUT
fi

