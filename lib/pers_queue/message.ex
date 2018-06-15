defmodule PersQueue.Message do
  defstruct [:id, :consumer, :content]

  @moduledoc """
  Module to manage a Message's state.

  Defines a `PersQueue.Message` struct.
  """

  @type t :: %PersQueue.Message{}

  @doc """
  Returns a new Message struct with defaults
  """
  @spec new(consumer :: String.t, content :: String.t) :: PersQueue.Message.t
  def new(consumer, content) do
    %PersQueue.Message{
      consumer: consumer,
      content: content
    }
  end
end
