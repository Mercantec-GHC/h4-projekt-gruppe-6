#!/bin/sh
RESPONSE=`curl -sSX POST http://localhost:5287/api/Users -d '{"Email":"hej@example.com","Username":"Gamer","Password":"Gamer123!"}' --header 'Content-Type: application/json' --write-out '\n%{http_code}' --output -`
HTTP_STATUS=`echo -n "$RESPONSE" | tail -n 1`
USER_ID=`echo "$RESPONSE" | head -n -1`

echo "POST /api/Users - $HTTP_STATUS"
echo -e "  User ID: $USER_ID\n"

RESPONSE=`curl -sSX POST http://localhost:5287/api/Users/login -d '{"Email":"hej@example.com","Password":"Gamer123!"}' --header 'Content-Type: application/json' --write-out '\n%{http_code}' --output -`
HTTP_STATUS=`echo -n "$RESPONSE" | tail -n 1`
TOKEN=`echo "$RESPONSE" | head -n -1`

echo "POST /api/Users/login - $HTTP_STATUS"
echo -e "  Received token: $TOKEN\n"

RESPONSE=`curl -sS http://localhost:5287/api/Users/$USER_ID --write-out '\n%{http_code}' --output -`
HTTP_STATUS=`echo -n "$RESPONSE" | tail -n 1`
USER_DATA=`echo "$RESPONSE" | head -n -1`

echo "GET /api/Users/$USER_ID - $HTTP_STATUS"
echo -e "  User data: $USER_DATA\n"

HTTP_STATUS=`curl -sSX DELETE http://localhost:5287/api/Users/$USER_ID --write-out '%{http_code}'`
echo "DELETE /api/Users/$USER_ID - $HTTP_STATUS"

