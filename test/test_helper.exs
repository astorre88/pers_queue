ExUnit.start()

defmodule Helpers.Persistence do
  alias PersQueue.Message
  alias PersQueue.Persistence

  def create_sample_messages do
    [
      %Message{content: "a", consumer: "consumer1"},
      %Message{content: "b", consumer: "consumer2"},
      %Message{content: "c", consumer: "consumer3"},
      %Message{content: "d", consumer: "consumer1"},
      %Message{content: "e", consumer: "consumer2"},
      %Message{content: "f", consumer: "consumer3"}
    ]
    |> Enum.map(&Persistence.insert/1)
  end
end
