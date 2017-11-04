defmodule Pubsub do
  @moduledoc """
  Documentation for Pubsub.
  """
  use Application

  alias Pubsub.Client

  @doc """
  """
  def start(_type, _args) do
    import Supervisor.Spec

    children = [worker(Client, [])]
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def create_topic(name) do
    GenServer.call(Pubsub.Client, {:create_topic, name})
  end

  def create_subscription(name, topic, opts \\ []) do
    GenServer.call(Pubsub.Client, {:create_subscription, name, topic, opts})
  end

  def publish(data, topic) do
    GenServer.call(Pubsub.Client, {:publish, data, topic})
  end

  def pull(subscription, opts \\ []) do
    GenServer.call(Pubsub.Client, {:pull, subscription, opts})
  end

  def acknowledge(ack_ids, subscription) do
    GenServer.call(Pubsub.Client, {:acknowledge, ack_ids, subscription})
  end
end
