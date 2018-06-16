defmodule PersQueue.Test.NQueue do
  use ExUnit.Case

  alias PersQueue.NQueue
  alias PersQueue.Message

  setup_all do
    [
      message1: Message.new("consumer", "a"),
      message2: Message.new("consumer", "b"),
      message3: Message.new("consumer", "c"),
      message4: Message.new("consumer", "d")
    ]
  end

  describe "NQueue object init" do
    test "returns queue with empty lists" do
      q = NQueue.new("consumer", [])

      assert q.consumer == "consumer"
      assert :queue.to_list(q.queued) == []
      assert q.running == []
    end

    test "returns queue with enqueued list", context do
      q = NQueue.new("consumer", [context[:message1], context[:message2], context[:message3]])

      assert :queue.to_list(q.queued) == [
               context[:message1],
               context[:message2],
               context[:message3]
             ]
    end

    test "returns queue with updated enqueued list", context do
      q =
        "consumer"
        |> NQueue.new([context[:message1], context[:message2], context[:message3]])
        |> NQueue.add(context[:message4])

      assert :queue.to_list(q.queued) == [
               context[:message1],
               context[:message2],
               context[:message3],
               context[:message4]
             ]
    end

    test "pops the message from the queue", context do
      {q, message} =
        "consumer"
        |> NQueue.new([context[:message1], context[:message2], context[:message3]])
        |> NQueue.get()

      assert message == context[:message1]
      assert :queue.to_list(q.queued) == [context[:message2], context[:message3]]
    end

    test "returns nil for empty queues" do
      {_q, message} =
        "consumer"
        |> NQueue.new([])
        |> NQueue.get()

      assert message == nil
    end

    test "pops the message from the queued and adds it to running", context do
      {q, message} =
        "consumer"
        |> NQueue.new([context[:message1], context[:message2], context[:message3]])
        |> NQueue.get()

      assert message == context[:message1]
      assert :queue.to_list(q.queued) == [context[:message2], context[:message3]]
      assert q.running == [context[:message1]]
    end

    test "ack removes the message from running", context do
      {q, message} =
        "consumer"
        |> NQueue.new([context[:message1], context[:message2], context[:message3]])
        |> NQueue.get()

      updated_queue = NQueue.ack(q, message.id)

      assert message == context[:message1]
      assert :queue.to_list(updated_queue.queued) == [context[:message2], context[:message3]]
      assert updated_queue.running == []
    end

    test "reject removes the message from running and move to end of enqueued", context do
      {q, message} =
        "consumer"
        |> NQueue.new([context[:message1], context[:message2], context[:message3]])
        |> NQueue.get()

      {updated_queue, rejected_message} = NQueue.reject(q, message.id)

      assert message == context[:message1]
      assert rejected_message == message

      assert :queue.to_list(updated_queue.queued) == [
               context[:message2],
               context[:message3],
               context[:message1]
             ]

      assert updated_queue.running == []
    end
  end
end
