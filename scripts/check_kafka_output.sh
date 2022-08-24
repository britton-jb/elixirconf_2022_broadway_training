docker compose -p elixir-conf-2022-broadway-training \
    exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
    --bootstrap-server kafka:9092 \
    --from-beginning \
    --property print.key=true \
    --topic postgres.public.vehicles

# docker run --tty \
# --network elixirconf_2022_broadway_training \
# confluentinc/cp-kafkacat \
# kafkacat -b kafka:9092 -C \
# -t postgres.public.vehicles

##
# Example payload portion of output:
#
# {
#   "payload": {
#     "before": null,
#     "after": {
#       "id":4381,
#       "start_x":1,
#       "start_y":1,
#       "current_x":1,
#       "current_y":1,
#       "is_on_journey":true,
#       "inserted_at":1660516006000,
#       "updated_at":1660516006000
#     }
#   }
# }