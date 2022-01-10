 
docker-compose down

sudo mvn clean install

sleep 5s

docker build -t oof-simulator .

sleep 2s

docker-compose up -d
