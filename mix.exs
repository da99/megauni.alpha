

defmodule Megauni.Mixfile do

  use Mix.Project

  def project do
    [
      app:             :megauni,
      version:         File.read!("VERSION") |> String.strip,
      elixir:          "~> 1.0",
      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: [
        {:cowboy   , "~> 1.0.0"},
        {:plug     , "~> 1.0.0"},
        {:postgrex , ">= 0.9.0"},
        {:poison   , "~> 1.5.0"},
        {:ecto     , "~> 1.0"},
        {:comeonin , "> 1.1.0"},
        {:timex    , "~> 0.19.5"}
      ]
    ]
  end

  def application do
    [
      mod: {Megauni, []},
      applications: [
        :cowboy,
        :comeonin,
        :ecto,
        :logger,
        :postgrex,
        :plug,
        :poison,
        :tzdata
      ]
    ]
  end

end # === defmodule Megauni.Mixfile
