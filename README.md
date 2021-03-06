# PersQueue
[![Build Status](https://api.travis-ci.org/astorre88/pers_queue.svg?branch=master)](https://travis-ci.org/astorre88/pers_queue)
[![Coverage Status](https://coveralls.io/repos/github/astorre88/pers_queue/badge.svg?branch=master)](https://coveralls.io/github/astorre88/pers_queue?branch=master)

The library implements persistent queue for Elixir applications.

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
