# One time registration of Kafka Topic
./scripts/connect_db_to_kafka.sh

# Do the consuming
docker compose exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
    --bootstrap-server kafka:9092 \
    --from-beginning \
    --property print.key=true \
    --topic postgres.public.vehicles

# quickly insert row
psql -U postgres -p postgres --host localhost --port 5433 --dbname vehicle_service -c "insert into vehicles (start_x, start_y, current_x, current_y, is_on_journey, inserted_at, updated_at) values (1,1,1,1,true,now(),now());"

# delete a connector
curl -X DELETE http://localhost:8083/connectors/vehicles-service-connector
