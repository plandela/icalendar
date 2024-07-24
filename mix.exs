defmodule ICalendar.Mixfile do
  use Mix.Project

  @version "1.1.0"

  def project do
    [
      app: :icalendar,
      version: @version,
      elixir: "~> 1.8",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ICalendar",
      source_url: "https://github.com/lpil/icalendar",
      description: "An ICalendar file generator",
      package: [
        maintainers: ["Louis Pilfold"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/lpil/icalendar"}
      ]
    ]
  end

  def application do
    [applications: [:calendar]]
  end

  defp deps do
    [
      # Markdown processor
      {:earmark, "~> 1.3", only: [:dev, :test]},
      # Documentation generator
      {:ex_doc, "~> 0.19", only: [:dev, :test]},

      # For full timezone support
      {:calendar, "~> 0.18"}
    ]
  end
end
