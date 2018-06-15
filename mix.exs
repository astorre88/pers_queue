defmodule PersQueue.MixProject do
  use Mix.Project

  def project do
    [
      app: :pers_queue,
      version: "0.0.1",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "PersQueue",
      source_url: "https://github.com/astorre88/pers_queue"
    ]
  end

  defp description do
    """
    The library implements persistent queue for Elixir applications.
    """
  end
  
  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Dmitry Vysotsky"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/astorre88/pers_queue"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {PersQueue, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Persistence backend
      {:amnesia, "~> 0.2"},

      # Code style
      {:credo, "~> 0.9.1", only: [:dev, :test], runtime: false},

      # Docs
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:inch_ex, "~> 0.5", only: [:dev, :test]}
    ]
  end
end
