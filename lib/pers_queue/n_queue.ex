defmodule PersQueue.NQueue do
  defstruct [:consumer, :queued, :running]

  @moduledoc """
  Module to manage a queue.

  Responsible for adding, fetching, acknowledging and rejecting messages in queue.
  Also keeps track of running messages.
  """

  @type t :: %PersQueue.NQueue{}

  @doc """
  Returns a new NQueue with defaults.
  """
  @spec new(consumer :: String.t, enqueued :: list(PersQueue.Messages.t)) :: PersQueue.NQueue.t
  def new(consumer, enqueued) do
    %PersQueue.NQueue{
      consumer: consumer,
      queued: :queue.from_list(enqueued),
      running: []
    }
  end

  @doc """
  Adds a message to the `queued` queue.
  """
  @spec add(q :: PersQueue.NQueue.t, message :: String.t) :: PersQueue.NQueue.t
  def add(%PersQueue.NQueue{queued: queued} = q, message) do
    %{q | queued: :queue.in(message, queued)}
  end

  @doc """
  Gets the next message in queue and returns a queue and message.
  """
  @spec get(q :: PersQueue.NQueue.t) :: {PersQueue.NQueue.t, PersQueue.Message.t | nil}
  def get(%PersQueue.NQueue{queued: queued, running: running} = q) do
    case :queue.out(queued) do
      {{_value, message}, queue2} ->
        {%{q | queued: queue2, running: [message | running]}, message}
      _ ->
        {q, nil}
    end
  end

  @doc """
  Acknowledges the running message, removes it from running list and returns a queue.
  """
  @spec ack(q :: PersQueue.NQueue.t, id :: pos_integer) :: PersQueue.NQueue.t
  def ack(%PersQueue.NQueue{running: running} = q, id) do
    %{q | running: Enum.reject(running, &(&1.id == id))}
  end

  @doc """
  Rejects the running message, enqueues it in queued queue and returns a queue and message.
  """
  @spec reject(q :: PersQueue.NQueue.t, id :: pos_integer) :: {PersQueue.NQueue.t, PersQueue.Message.t | nil}
  def reject(%PersQueue.NQueue{running: running, queued: queued} = q, id) do
    case Enum.find(running, &(&1.id == id)) do
      nil ->
        {q, nil}
      rejected ->
        {%{q | running: Enum.reject(running, &(&1.id == id)), queued: :queue.in(rejected, queued)}, rejected}
    end
  end
end
