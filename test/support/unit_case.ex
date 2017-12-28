defmodule Weddell.UnitCase do
  use ExUnit.CaseTemplate

  alias Weddell.{PublisherStubMock,
                 SubscriberStubMock}

  using do
    quote do
      alias Weddell.{PublisherStubMock,
                     SubscriberStubMock}
    end
  end

  setup_all do
    Application.put_env(:weddell, :publisher_stub, PublisherStubMock)
    Application.put_env(:weddell, :subscriber_stub, SubscriberStubMock)
  end
end
