# Weddell

[![Build Status](https://travis-ci.org/cjab/weddell.svg?branch=master)](https://travis-ci.org/cjab/weddell)
[![Inline docs](https://inch-ci.org/github/cjab/weddell.svg)](https://inch-ci.org/github/cjab/weddell)

Weddell is an Elixir client for [Google Pub/Sub](https://cloud.google.com/pubsub/).

[Documentation](https://hexdocs.pm/weddell)

## Installation

1) Add Weddell and Goth to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:weddell, "~> 0.1.0-alpha.1"},
    {:goth, "~> 0.11.0"},
  ]
end
```

2) Configure Weddell and Goth with your GCP service account credentials:

```elixir
config :weddell,
  project: "gcp-project-name"
config :goth,
  json: {:system, "GCP_CREDENTIALS_JSON"}
```

## Getting Started

### Creating a topic and subscription

```elixir
Weddell.create_topic("topic-name")
Weddell.create_subscription("subscription-name", "topic-name")
```

### Creating a consumer

```elixir
# In your application code
defmodule MyApp.Consumer do
  use Weddell.Consumer

  def handle_messages(messages) do
    %{true => processed_messages, false => failed_messages} =
      Enum.group_by(messages, &process_message/1)
    # Delay failed messages for at least 60 seconds
    delay_messages =
      Enum.map(failed_messages, fn msg -> {msg, 60} end)
    {:ok, ack: processed_messages, delay: delay_messages}
  end

  def process_message(message) do
    ...
  end
end

defmodule MyApp do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      {MyApp.Consumer, "subscription-name"}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

### Publishing a message

#### With data

```elixir
"data"
|> Weddell.publish("topic-name")
```

#### With json data

```elixir
%{foo: "bar"}
|> Poison.encode!()
|> Weddell.publish("topic-name")
```

#### With data and attributes

```elixir
{"data", %{attr1: "value1"}}
|> Weddell.publish("topic-name")
```

#### With only attributes

```elixir
%{attr1: "value1"}
|> Weddell.publish("topic-name")
```

#### Multiple messages

```elixir
["message1", "message2", "message3"]
|> Weddell.publish("topic-name")

[{"message1", %{attr1: "value1"}},
 {"message2", %{attr2: "value2"}},
 {"message3", %{attr3: "value3"}}]
|> Weddell.publish("topic-name")
```

## TODO

- [X] Integration tests
- [ ] Update topics
- [ ] Update subscriptions
- [ ] Modify ack deadline (non-streaming)
- [ ] GRPC stream error handling
- [ ] Snapshots?

## Alternatives

Weddell uses Pub/Sub's GRPC API which is still in beta. It also
makes use of streaming APIs that are considered experimental. If the
beta/experimental status of Weddell worries you [Kane](https://github.com/peburrows/kane)
may be a better choice. It uses the more mature Pub/Sub REST API.
