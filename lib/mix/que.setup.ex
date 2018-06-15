defmodule Mix.Tasks.PersQueue.Setup do
  use Mix.Task

  @moduledoc """
  Creates an Mnesia DB on disk for PersQueue.
  """

  def run(_) do
    PersQueue.Persistence.setup
  end
end
