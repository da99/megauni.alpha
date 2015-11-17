

defmodule Megauni.Mixfile do

  use Mix.Project

  def project do
    [app: :megauni,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [
      applications: [
        :logger, :postgrex,
        :ecto, :cowboy,
        :plug, :poison,
        :comeonin, :tzdata
      ],

      mod: {Megauni, []}
    ]
  end

  defp deps do
    [
      {:cowboy   , "~> 1.0.0"},
      {:plug     , "~> 1.0.0"},
      {:postgrex , ">= 0.9.0"},
      {:poison   , "~> 1.5.0"},
      {:ecto     , "~> 1.0"},
      {:comeonin , "> 1.1.0"},
      {:timex    , "~> 0.19.5"}
    ]
  end

end # === defmodule Megauni.Mixfile
