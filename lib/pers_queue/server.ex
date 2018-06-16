defmodule PersQueue.Server do
  use GenServer

  @moduledoc """
  `PersQueue.Server` is the `GenServer` responsible for processing all messages.
  """

  # API

  @doc """
  Starts the message Server
  """
  @spec start_link(consumer :: String.t()) :: GenServer.on_start()
  def start_link(consumer) do
    GenServer.start_link(__MODULE__, {:ok, consumer}, name: from(consumer))
  end

  @doc """
  Creates a new message with the passed content.
  """
  @spec add(consumer :: String.t(), message_content :: String.t()) :: :ok
  def add(consumer, message_content) do
    GenServer.call(from(consumer), {:add, consumer, message_content})
  end

  @doc """
  Gets the message from the head of the queue.
  """
  @spec get(consumer :: String.t()) :: :ok
  def get(consumer) do
    GenServer.call(from(consumer), :get)
  end

  @doc """
  Acks the message.
  """
  @spec ack(consumer :: String.t(), message_id :: pos_integer) :: :ok
  def ack(consumer, message_id) do
    GenServer.call(from(consumer), {:ack, message_id})
  end

  @doc """
  Rejects the message.
  """
  @spec reject(consumer :: String.t(), message_id :: pos_integer) :: :ok
  def reject(consumer, message_id) do
    GenServer.call(from(consumer), {:reject, message_id})
  end

  # Server

  @doc false
  def init({:ok, consumer}) do
    enqueued = PersQueue.Persistence.enqueued(consumer)

    queue = PersQueue.NQueue.new(consumer, enqueued)

    {:ok, queue}
  end

  @doc """
  Persists the message and adds it to the queue.
  """
  def handle_call({:add, consumer, message_content}, _from, queue) do
    message =
      consumer
      |> PersQueue.Message.new(message_content)
      |> PersQueue.Persistence.insert()

    updated_queue =
      queue
      |> PersQueue.NQueue.add(message)

    {:reply, :ok, updated_queue}
  end

  @doc """
  Pops the message from the queue and removes it from the DB.
  """
  def handle_call(:get, _from, queue) do
    case PersQueue.NQueue.get(queue) do
      {queue, nil} ->
        {:reply, nil, queue}

      {updated_queue, message} ->
        PersQueue.Persistence.delete(message.id)
        {:reply, message, updated_queue}
    end
  end

  @doc """
  Removes the message from the running list.
  """
  def handle_call({:ack, message_id}, _from, queue) do
    updated_queue = PersQueue.NQueue.ack(queue, message_id)

    {:reply, :ok, updated_queue}
  end

  @doc """
  Removes the message from the running list and enqueues it to the queue.
  """
  def handle_call({:reject, message_id}, _from, queue) do
    case PersQueue.NQueue.reject(queue, message_id) do
      {^queue, nil} ->
        {:reply, nil, queue}

      {updated_queue, rejected} ->
        # Resets message id to save the order of queue
        PersQueue.Persistence.insert(%{rejected | id: nil})
        {:reply, :ok, updated_queue}
    end
  end

  @doc """
  Checks if the associated with consumer process exists.
  """
  def exists?(consumer) do
    consumer
    |> from
    |> GenServer.whereis()
  end

  defp from(consumer) do
    {:global, {__MODULE__, consumer}}
  end
end
