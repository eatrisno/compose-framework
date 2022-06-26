docker-compose up -d
docker-compose exec nginx sh -c "nginx -t && nginx -s reload"