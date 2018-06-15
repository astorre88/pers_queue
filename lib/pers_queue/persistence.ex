defmodule PersQueue.Persistence do
  use Amnesia

  @moduledoc """
  Mnesia adapter to persist `PersQueue.Messages`s
  """

  @db Module.concat(__MODULE__, DB)
  @store Module.concat(@db, Messages)

  def setup(nodes \\ [node()]) do
    Amnesia.stop
    Amnesia.Schema.create(nodes)
    Amnesia.start

    @db.create!(disk: nodes)
    @db.wait(15_000)
  end

  defdatabase DB do
    deftable Messages, [{:id, autoincrement}, :consumer, :content], type: :ordered_set do
      @type t :: %Messages{id: non_neg_integer, consumer: String.t, content: String.t}

      @store __MODULE__

      def enqueued_messages do
        Amnesia.transaction do
          keys()
          |> match
          |> parse_selection
        end
      end

      def enqueued_messages(name) do
        Amnesia.transaction do
          parse_selection(where(consumer == name))
        end
      end

      def create_message(message) do
        Amnesia.transaction do
          message
          |> to_db_message
          |> write
          |> to_que_message
        end
      end

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
