defmodule Nerves.Grove.Mixfile do
  use Mix.Project

  @name "Nerves.Grove"
  @version File.read!("VERSION") |> String.trim()
  @github "https://github.com/bendiken/nerves_grove"
  @bitbucket "https://bitbucket.org/bendiken/nerves_grove"
  @homepage @github

  def project do
    [
      app: :nerves_grove,
      version: @version,
      elixir: "~> 1.3",
      compilers: Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      name: @name,
      source_url: @github,
      homepage_url: @homepage,
      description: description(),
      aliases: aliases(),
      deps: deps(),
      package: package(),
      docs: [source_ref: @version, main: "readme", extras: ["README.md"]],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp package do
    [
      files: ~w(lib mix.exs CHANGES.md README.md UNLICENSE VERSION),
      maintainers: ["Arto Bendiken"],
      licenses: ["Public Domain"],
      links: %{"GitHub" => @github, "Bitbucket" => @bitbucket}
    ]
  end

  defp description do
    """
    Grove module support for Nerves.
    """
  end

  defp deps do
    [
      {:elixir_ale, "~> 1.1"},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:earmark, "~> 1.2", only: :dev, runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test, runtime: false},
      {:gpio_rpi, "~> 0.2.2"},
      {:pigpiox, "~> 0.1"}
    ]
  end

  defp aliases do
    []
  end
end
