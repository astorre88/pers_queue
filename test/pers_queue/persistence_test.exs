defmodule PersQueue.Test.Persistence do
  use ExUnit.Case

  alias PersQueue.Persistence

  setup do
    Persistence.DB.destroy
    Persistence.DB.create
    :ok
  end

  test "returns empty list when there are no enqueued messages in DB" do
    assert Persistence.enqueued == []
  end

  test "returns enqueued messages present in DB" do
    messages = Helpers.Persistence.create_sample_messages

    assert Persistence.enqueued == messages
  end

  test "finds enqueued messages for a connection" do
    assert Persistence.enqueued == []

    [a1, b1, c1, a2, b2, c2] = Helpers.Persistence.create_sample_messages

    assert [a1, a2] == Persistence.enqueued("consumer1")
    assert [b1, b2] == Persistence.enqueued("consumer2")
    assert [c1, c2] == Persistence.enqueued("consumer3")
  end

  test "adds message to the db" do
    assert Persistence.enqueued == []

    Persistence.insert(%PersQueue.Message{content: "a"})
    messages = Persistence.enqueued

    assert length(messages) == 1
    assert hd(messages).content == "a"
  end

  test "removes message from DB" do
    assert [a1, b1, c1, a2, b2, c2] = Helpers.Persistence.create_sample_messages

    Persistence.delete(b1.id)

    assert [a1, c1, a2, b2, c2] == Persistence.enqueued
  end
end
