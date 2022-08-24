import Config

config :csv_reader, CsvReader.Scheduler,
  jobs: [
    # Every minute
    {"* * * * *", {CsvReader, :read_csv, []}}
  ]
