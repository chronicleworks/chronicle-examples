#!/bin/bash

# Authorization
read -er -p "Enter bearer token: " wstoken
wstoken=${wstoken:-beertoken}

# Chronicle host
read -er -p "Enter hostname: " wshost
wshost=${wshost:-127.0.0.1}

# Chronicle port
read -er -p "Enter port: " wsport
wsport=${wsport:-9982}

wsendpoint="ws://$wshost:$wsport/ws"

echo "Establishing subscription"

echo "Using bearer token: $wstoken"
echo "Using ws end point: $wsendpoint"

read -r -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

echo "subscription{ commitNotifications {stage,txId,delta,error}}" | gql-cli \
  --headers "Authorization: Bearer $wstoken" \
  --transport websockets -v "$wsendpoint"

exit 0
