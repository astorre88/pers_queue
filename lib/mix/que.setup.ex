defmodule Mix.Tasks.PersQueue.Setup do
  use Mix.Task

  @moduledoc """
  Creates an Mnesia DB on disk for PersQueue.
  """

  @doc """
  Setups persistence back.
  """
  def run(_) do
    PersQueue.Persistence.setup()
  end
end
