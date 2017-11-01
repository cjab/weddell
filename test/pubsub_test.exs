defmodule PubsubTest do
  use ExUnit.Case
  doctest Pubsub

  test "greets the world" do
    assert Pubsub.hello() == :world
  end
end
