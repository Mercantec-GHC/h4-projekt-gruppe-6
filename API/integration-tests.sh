#!/bin/sh

RESPONSE=`curl -sSLX POST http://localhost:5287/api/Users -d '{"Email":"hej@example.com","Username":"Gamer","Password":"Gamer123!"}' -H 'Content-Type: application/json' -H 'Accept: */*' -w '\n%{http_code}'`
HTTP_STATUS=`echo -n "$RESPONSE" | tail -n 1`
USER_ID=`echo "$RESPONSE" | head -n -1`

echo "POST /api/Users - $HTTP_STATUS"

if [ $HTTP_STATUS -ne 200 ]
then
	echo $RESPONSE
	exit
fi

echo -e "  User ID: $USER_ID\n"

RESPONSE=`curl -sSLX POST http://localhost:5287/api/Users/login -d '{"Email":"hej@example.com","Password":"Gamer123!"}' -H 'Content-Type: application/json' -H 'Accept: */*'  -w '\n%{http_code}'`
HTTP_STATUS=`echo -n "$RESPONSE" | tail -n 1`
TOKEN=`echo "$RESPONSE" | head -n -1`

echo "POST /api/Users/login - $HTTP_STATUS"

if [ $HTTP_STATUS -ne 200 ]
then
	echo $RESPONSE
	exit
fi

echo -e "  Received token: $TOKEN\n"

RESPONSE=`curl -sSL http://localhost:5287/api/Users/$USER_ID -w '\n%{http_code}' -H 'Accept: */*'`
HTTP_STATUS=`echo -n "$RESPONSE" | tail -n 1`
USER_DATA=`echo "$RESPONSE" | head -n -1`

echo "GET /api/Users/$USER_ID - $HTTP_STATUS"

if [ $HTTP_STATUS -ne 200 ]
then
	echo $RESPONSE
	exit
fi

echo -e "  User data: $USER_DATA\n"

RESPONSE=`curl -sSLX DELETE http://localhost:5287/api/Users/$USER_ID --location-trusted -w '%{http_code}' -H "Authorization: Bearer $TOKEN" -H 'Accept: */*'`
HTTP_STATUS=`echo -n "$RESPONSE" | tail -n 1`

echo "DELETE /api/Users/$USER_ID - $HTTP_STATUS"

if [ $HTTP_STATUS -ne 200 ]
then
	echo $RESPONSE
	exit
fi

