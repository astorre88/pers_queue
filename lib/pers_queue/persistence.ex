defmodule PersQueue.Persistence do
  use Amnesia

  @moduledoc """
  Mnesia adapter to persist `PersQueue.Messages`s
  """

  @db Module.concat(__MODULE__, DB)
  @store Module.concat(@db, Messages)

  @doc """
  Creates the Mnesia Database for `PersQueue` on disk

  This creates the Schema, Database and Tables for
  PersQueue Messages on disk for the specified erlang nodes so
  Messages are persisted across application restarts.
  Calling this momentarily stops the `:mnesia`
  application so you should make sure it's not being
  used when you do.

  The database is creates for the current node.
  """
  @spec setup(nodes :: list(node)) :: :ok
  def setup(nodes \\ [node()]) do
    Amnesia.stop
    Amnesia.Schema.create(nodes)
    Amnesia.start

    @db.create!(disk: nodes)
    @db.wait(15_000)
  end

  defdatabase DB do
    @moduledoc false
    deftable Messages, [{:id, autoincrement}, :consumer, :content], type: :ordered_set do
      @type t :: %Messages{id: non_neg_integer, consumer: String.t, content: String.t}

      @store __MODULE__
      @moduledoc false

      @doc "Finds all enqueued messages"
      def enqueued_messages do
        Amnesia.transaction do
          keys()
          |> match
          |> parse_selection
        end
      end

      @doc "Find all enqueued messages for a consumer"
      def enqueued_messages(name) do
        Amnesia.transaction do
          parse_selection(where(consumer == name))
        end
      end

      @doc "Inserts a new message in to DB"
      def create_message(message) do
        Amnesia.transaction do
          message
          |> to_db_message
          |> write
          |> to_que_message
        end
      end

      @doc "Deletes a message from the DB"
      def delete_message(message_id) do
        Amnesia.transaction do
          delete(message_id)
        end
      end

      defp to_db_message(%PersQueue.Message{} = message) do
        struct(@store, Map.from_struct(message))
      end

      defp to_que_message(nil), do: nil
      defp to_que_message(%@store{} = message) do
        struct(PersQueue.Message, Map.from_struct(message))
      end

      defp parse_selection(selection) do
        selection
        |> Amnesia.Selection.values
        |> Enum.map(&to_que_message/1)
      end
    end
  end

  @doc false
  def start do
    @db.create
  end

  @doc """
  Returns enqueued `PersQueue.Message`s from the database.
  """
  @spec enqueued :: list(PersQueue.Message.t)
  defdelegate enqueued, to: @store, as: :enqueued_messages

  @doc """
  Returns all enqueued `PersQueue.Message`s for the given consumer.
  """
  @spec enqueued(consumer :: String.t) :: list(PersQueue.Message.t)
  defdelegate enqueued(consumer), to: @store, as: :enqueued_messages

  @doc """
  Inserts a `PersQueue.Message` into the database.

  Returns the same Message struct with the `id` value set
  """
  @spec insert(message :: String.t) :: PersQueue.Message.t
  defdelegate insert(message), to: @store, as: :create_message

  @doc """
  Deletes a `PersQueue.Message` from the database.
  """
  @spec delete(message_id :: pos_integer) :: :ok | no_return
  defdelegate delete(message_id), to: @store, as: :delete_message
end
