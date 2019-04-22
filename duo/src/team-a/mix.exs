defmodule MyProject.MixProject do
  use Mix.Project

  def project() do
    [
      app: :my_project,
      version: "0.0.1",
      elixir: "~> 1.0",
      deps: deps(),
    ]
  end

  def application() do
    []
  end

  defp deps() do
    [
      { :statistics, "~> 0.5.0"}
    ]
  end
end
