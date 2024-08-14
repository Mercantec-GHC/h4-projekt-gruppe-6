USER_ID=`curl -X POST http://localhost:5287/api/Users -d '{"Email":"hej@example.com","Username":"Gamer","Password":"Gamer123!"}' --header 'Content-Type: application/json'`

TOKEN=`curl -X POST http://localhost:5287/api/Users/login -d '{"Email":"hej@example.com","Password":"Gamer123!"}' --header 'Content-Type: application/json'`

curl http://localhost:5287/api/Users/$USER_ID

curl -X DELETE http://localhost:5287/api/Users/$USER_ID

