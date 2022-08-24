curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d '
{
    "name": "vehicles-service-connector",
    "config": {
        "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
        "database.dbname" : "vehicle_service",
        "database.hostname": "postgres",
        "database.password": "postgres",
        "database.port": "5432",
        "database.server.name": "postgres",
        "database.user": "postgres",
        "schema.include.list": "public",
        "plugin.name": "pgoutput",
        "tasks.max": "1"
    }
}'