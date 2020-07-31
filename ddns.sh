#/bin/bash

ZONE_NAME='example.com'
#Enter your DNS zone name there.
EMAIL='someone@example.com'
#Your auth email.
RECORD_NAME='record.example.com'
#Enter your FULL DNS record name there.
RECORD_TYPE='record'
#Record name.
AUTH_KEY='xxxxxxxxxxxxxxxxxxxxxxxxx'
#Auth key there. This can be found in your account settings.
TTL=1
#TTL value dor your record. Type "1" for auto.

ip=$(
     ip -6 addr list scope global $device | grep -v " fd" | sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | head -n 1
)
echo "Your ip address is $ip ."

zoneid=$(
     curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$ZONE_NAME" \
     -H "X-Auth-Email: $EMAIL" \
     -H "X-Auth-Key: $AUTH_KEY" \
     -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1
)
echo "Your cloudflare DNS zone id is $zoneid . "

dnsidenty=$(
     curl  -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?name=$RECORD_NAME" \
     -H "X-Auth-Email: $EMAIL" \
     -H "X-Auth-Key: $AUTH_KEY" \
     -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*'
)
echo "The cloudflare DNS record identy is $dnsidenty ."

dnsrecord=$(
     curl -s  -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=$RECORD_TYPE&name=$RECORD_NAME" \
     -H "X-Auth-Email: $EMAIL" \
     -H "X-Auth-Key: $AUTH_KEY" \
     -H "Content-Type: application/json" |  grep -Po '(?<="content":")[^"]*'
)
echo  "The DNS record on the server is $dnsrecord ."

if [ "$ip" == "$dnsrecord" ] ; then
     echo "Address Unchanged."
else
     #Here we are ready to update your DNS record below.
     curl  -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsidenty" \
          -H "X-Auth-Email: $EMAIL" \
          -H "X-Auth-Key: $AUTH_KEY" \
          -H "Content-Type: application/json" \
          --data '{"type":"'${RECOED_TYPE}'","name":"'${RECORD_NAME}'","content":"'${ip}'","ttl":'${TTL}',"proxied":false}'
     echo  -e "Address updated."
fi
