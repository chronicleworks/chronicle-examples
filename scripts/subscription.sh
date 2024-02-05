#!/bin/bash

# Chronicle host
read -erp "Enter hostname: " wshost
wshost=${wshost:-127.0.0.1}

# Chronicle port
read -erp "Enter port: " wsport
wsport=${wsport:-9982}

# Authorization
read -erp "Enter bearer token: " wstoken
wstoken=${wstoken:-beertoken}

echo "$wshost"
echo "$wsport"
echo "$wstoken"

read -rp "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

echo "subscription{ commitNotifications {stage,txId,delta,error}}" | gql-cli \
  --headers "Authorization: Bearer $wstoken" \
  --transport websockets -v ws://"$wshost":"$wsport"/ws

exit 0
