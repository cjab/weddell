defmodule Weddell.ClientTest do
  use ExUnit.Case

  alias Weddell.{PublisherStubMock, SubscriberStubMock}

  setup do
    Application.stop(:weddell)
    Application.put_env(:weddell, :publisher_stub, PublisherStubMock)
    Application.put_env(:weddell, :subscriber_stub, SubscriberStubMock)
    Application.put_env(:weddell, :project, "weddell")
    Application.delete_env(:weddell, :no_connect_on_start)
  end

  describe "Weddell application" do
    test "starts with a client by default" do
      nil = GenServer.whereis(Weddell.Client)
      Application.start(:weddell)
      pid = wait_for_server(Weddell.Client, 100)
      true = is_pid(pid)
      %Weddell.Client{} = Weddell.client()
    end

    test "starts without a client if :no_connect_on_start is set" do
      Application.put_env(:weddell, :no_connect_on_start, true)
      nil = GenServer.whereis(Weddell.Client)
      Application.start(:weddell)
      # assert_raise
      nil = wait_for_server(Weddell.Client, 100)
      assert {:noproc, _} = catch_exit(Weddell.client())
      nil = GenServer.whereis(Weddell.Client)
    end

    test "client can be started separately" do
      Application.put_env(:weddell, :no_connect_on_start, true)
      nil = GenServer.whereis(Weddell.Client)
      Application.start(:weddell)

      {:ok, pid} =
        Weddell.Client.start_link(
          "myproject",
          Application.get_all_env(:weddell),
          name: :my_client
        )

      true = is_pid(pid)

      %Weddell.Client{} = GenServer.call(:my_client, {:client})
    end
  end

  defp wait_for_server(server, 0) do
    nil
  end

  defp wait_for_server(server, timeout) do
    case GenServer.whereis(server) do
      nil ->
        :timer.sleep(10)
        wait_for_server(server, timeout - 10)

      pid ->
        pid
    end
  end
end
