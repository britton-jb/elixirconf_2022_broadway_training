defmodule CsvReader do
  # Implement CsvReader.read_csv/0
  #   Establish a connection to RabbitMQ
  #   Open up, and iterate over, the vehicles.csv in the project root
  #   Convert each row to a JSON object
  #   Publish each row, one by one, to a queue called “vehicle_registry”
  #   https://hexdocs.pm/amqp/readme.html
  end
