defmodule Weddell.IntegrationCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @moduletag :integration
    end
  end

  setup_all do
    Application.stop(:weddell)
    Application.put_env(:weddell, :publisher_stub, Google.Pubsub.V1.Publisher.Stub)
    Application.put_env(:weddell, :subscriber_stub, Google.Pubsub.V1.Subscriber.Stub)
    Application.put_env(:weddell, :scheme, :http)
    Application.put_env(:weddell, :host, "localhost")
    Application.put_env(:weddell, :port, 8085)
    Application.put_env(:weddell, :project, "weddell")
    Application.start(:weddell)
  end
end
