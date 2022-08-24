defmodule CsvReader.MixProject do
  use Mix.Project

  def project do
    [
      app: :csv_reader,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:amqp, :logger],
      mod: {CsvReader.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:amqp, "~> 3.1"},
      {:csv, "~> 2.4"},
      {:jason, "~> 1.3"},
      {:quantum, "~> 3.5"}
    ]
  end
end
