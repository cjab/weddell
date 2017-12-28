defmodule Weddell.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @moduletag :integration
    end
  end

  setup_all do
    Application.put_env(:weddell, :publisher_stub, Google.Pubsub.V1.Publisher.Stub)
    Application.put_env(:weddell, :subscriber_stub, Google.Pubsub.V1.Subscriber.Stub)
  end
end
