defmodule Xandra.Mixfile do
  use Mix.Project

  @description "Fast, simple, and robust Cassandra driver for Elixir."

  @repo_url "https://github.com/lexhide/xandra"

  @version "0.13.1"

  def project() do
    [
      app: :xandra,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Task aliases
      aliases: ["test.scylladb": "test --exclude encryption --exclude cassandra_specific"],
      preferred_cli_env: ["test.scylladb": :test],

      # Dialyzer
      dialyzer: [flags: [:no_contracts]],

      # Hex
      package: package(),
      description: @description,

      # Docs
      name: "Xandra",
      docs: [
        main: "Xandra",
        source_ref: "v#{@version}",
        source_url: @repo_url,
        extras: [
          "pages/Data types comparison table.md"
        ]
      ]
    ]
  end

  def application() do
    [extra_applications: [:logger]]
  end

  defp package() do
    [
      maintainers: ["Aleksei Magusev", "Andrea Leopardi"],
      licenses: ["ISC"],
      links: %{"GitHub" => @repo_url}
    ]
  end

  defp deps() do
    [
      {:db_connection, "~> 2.0"},
      {:connection, "~> 1.0"},
      {:decimal, "~> 1.7", optional: true},

      # Dev and test dependencies
      {:snappy, github: "skunkwerks/snappy-erlang-nif", tag: "1.1.2", only: [:dev, :test]},
      {:ex_doc, "~> 0.20", only: :dev},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false}
    ]
  end
end
