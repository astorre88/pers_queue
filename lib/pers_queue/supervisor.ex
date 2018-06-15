defmodule PersQueue.Supervisor do
  use Supervisor

  @moduledoc """
  This is the `Supervisor` responsible for overseeing the entire
  `PersQueue` application.
  """

  @doc """
  Starts the supervision tree for `PersQueue`
  """
  @spec start_link() :: Supervisor.on_start
  def start_link do
    PersQueue.Persistence.start
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc false
  def init(:ok) do
    children = [
      supervisor(PersQueue.ServerSupervisor, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
