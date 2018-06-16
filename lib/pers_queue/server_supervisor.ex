defmodule PersQueue.ServerSupervisor do
  use Supervisor

  @moduledoc """
  This Supervisor is responsible for spawning a `PersQueue.Server`
  for each consumer.
  """

  @doc """
  Starts the supervision tree
  """
  @spec start_link() :: Supervisor.on_start()
  def start_link do
    pid = Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    resume_processes()
    pid
  end

  @doc """
  Starts a `PersQueue.Server` for the given consumer
  """
  @spec start_server(consumer :: String.t()) :: Supervisor.on_start_child() | no_return
  def start_server(consumer) do
    Supervisor.start_child(__MODULE__, [consumer])
  end

  @doc """
  Resends add task to server.
  If the server for the consumer is running, add message to it.
  If not, spawn a new server first and then add it.
  """
  @spec add(consumer :: String.t(), message_content :: String.t()) :: :ok
  def add(consumer, message_content) do
    unless PersQueue.Server.exists?(consumer) do
      start_server(consumer)
    end

    PersQueue.Server.add(consumer, message_content)
  end

  @doc """
  Resends get task to server.
  """
  @spec get(consumer :: String.t()) :: :ok
  def get(consumer) do
    PersQueue.Server.get(consumer)
  end

  @doc """
  Resends ack task to server.
  """
  @spec ack(consumer :: String.t(), message_id :: pos_integer) :: :ok
  def ack(consumer, message_id) do
    PersQueue.Server.ack(consumer, message_id)
  end

  @doc """
  Resends reject task to server.
  """
  @spec reject(consumer :: String.t(), message_id :: pos_integer) :: :ok
  def reject(consumer, message_id) do
    PersQueue.Server.reject(consumer, message_id)
  end

  @doc false
  def init(:ok) do
    children = [
      worker(PersQueue.Server, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  defp resume_processes do
    PersQueue.Persistence.enqueued()
    |> Enum.group_by(& &1.consumer)
    |> Map.keys()
    |> Enum.map(&start_server/1)
  end
end
