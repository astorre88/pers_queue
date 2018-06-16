defmodule PersQueue do
  use Application

  @moduledoc """
  `PersQueue` is persistent queue with `Mnesia` backend.


  ## Installation

  1) Add `pers_queue` to your deps:

  ```elixir
  def deps do
    [
      {:pers_queue, "~> 0.0.1"}
    ]
  end
  ```
  2) Add `pers_queue` to the list of application dependencies:

  ```elixir
  def application do
    [applications: [:pers_queue]]
  end
  ```


  ## Persistent Setup

  PersQueue runs out of the box, but by default all messages are stored in-memory.
  To persist messages across application restarts, run the following mix task:

  ```bash
  $ mix pers_queue.setup
  ```

  This will create the Mnesia schema and message database for you.


  ## Usage

  ```elixir
  # Add message:
  PersQueue.add("consumer1", "a")  # => :ok
  PersQueue.add("consumer1", "b")  # => :ok

  # Get message:
  PersQueue.get("consumer1")       # => %PersQueue.Message{consumer: "consumer1", content: "a", id: 1}
  PersQueue.get("consumer1")       # => %PersQueue.Message{consumer: "consumer1", content: "b", id: 2}

  # Ack message by message id:
  PersQueue.ack("consumer1", 1)    # => :ok

  # Reject message by message id:
  PersQueue.reject("consumer1", 2) # => :ok
  ```
  """

  @doc """
  Starts the PersQueue application
  """
  def start(_type, _args) do
    PersQueue.Supervisor.start_link()
  end

  @doc """
  Enqueues a message to persistent queue.

  Accepts the consumer name and message content.

  ## Example

  ```
  PersQueue.add("consumer1", "a") # => :ok

  PersQueue.add("consumer2", "b") # => :ok
  ```
  """
  @spec add(consumer :: String.t(), message_content :: String.t()) :: :ok
  defdelegate add(consumer, message_content), to: PersQueue.ServerSupervisor

  @doc """
  Gets a message from persistent queue.

  Accepts the consumer name.

  ## Example

  ```
  PersQueue.get("consumer1") # => %PersQueue.Message{consumer: "consumer1", content: "a", id: 1}
  ```
  """
  @spec get(consumer :: String.t()) :: PersQueue.Message.t()
  defdelegate get(consumer), to: PersQueue.ServerSupervisor

  @doc """
  Acks a message and deletes it from running list.

  Accepts the consumer name and message id.

  ## Example

  ```
  PersQueue.ack("consumer1", 1) # => :ok
  ```
  """
  @spec ack(consumer :: String.t(), message_id :: pos_integer) :: :ok
  defdelegate ack(consumer, message_id), to: PersQueue.ServerSupervisor

  @doc """
  Rejects a message and moves it to the end of persistent queue.

  Accepts the consumer name and message id.

  ## Example

  ```
  PersQueue.reject("consumer1", 1) # => :ok
  ```
  """
  @spec reject(consumer :: String.t(), message_id :: pos_integer) :: :ok
  defdelegate reject(consumer, message_id), to: PersQueue.ServerSupervisor
end
