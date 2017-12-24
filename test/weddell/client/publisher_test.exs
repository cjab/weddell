defmodule Weddell.Client.PublisherTest do
  use ExUnit.Case

  import Mox

  alias GRPC.RPCError
  alias Google.Protobuf.Empty
  alias Google.Pubsub.V1.{Topic,
                          PublishResponse,
                          ListTopicsResponse}
  alias Weddell.{Client,
                 Client.Util,
                 TopicDetails,
                 Client.Publisher,
                 PublisherStubMock}

  Application.put_env(:weddell, :publisher_stub, PublisherStubMock)

  @project "test-project"
  @topic "test-topic"

  describe "Publisher.create_topic/2" do
    setup [:setup_client, :stub_create_topic, :verify_on_exit!]

    test "create a topic", %{client: client} do
      name = Util.full_topic(@project, @topic)
      PublisherStubMock
      |> expect(:create_topic, fn _, %{name: ^name}, _ ->
        {:ok, %Topic{}}
      end)
      assert :ok ==
        Publisher.create_topic(client, @topic)
    end

    test "error creating topic", %{client: client} do
      error = %RPCError{}
      PublisherStubMock
      |> expect(:create_topic, fn _, _, _ ->
        {:error, error}
      end)
      assert {:error, error} ==
        Publisher.create_topic(client, @topic)
    end
  end

  describe "Publisher.delete_topic/2" do
    setup [:setup_client, :stub_delete_topic, :verify_on_exit!]

    test "delete a topic", %{client: client} do
      topic = Util.full_topic(@project, @topic)
      PublisherStubMock
      |> expect(:delete_topic, fn _, %{topic: ^topic}, _ ->
        {:ok, %Empty{}}
      end)
      assert :ok ==
        Publisher.delete_topic(client, @topic)
    end

    test "error deleting a topic", %{client: client} do
      error = %RPCError{}
      PublisherStubMock
      |> expect(:delete_topic, fn _, _, _ ->
        {:error, error}
      end)
      assert {:error, error} ==
        Publisher.delete_topic(client, @topic)
    end
  end

  describe "Publisher.topics/2" do
    setup [:setup_client, :stub_list_topics, :verify_on_exit!]

    test "list all topics without paging", %{client: client} do
      project = Util.full_project(client.project)
      topic = %Topic{name: Util.full_topic(client.project, @topic)}
      topics = [topic, topic]
      PublisherStubMock
      |> expect(:list_topics, fn
        (_, %{project: ^project, page_size: 50}, _) ->
          {:ok, %ListTopicsResponse{topics: topics}}
      end)
      assert {:ok, [TopicDetails.new(topic), TopicDetails.new(topic)]} ==
        Publisher.topics(client)
    end

    test "list all topics with paging", %{client: client} do
      project = Util.full_project(client.project)
      topic = %Topic{name: Util.full_topic(client.project, @topic)}
      topics = [topic, topic]
      cursor = "page-token"
      max = 100
      PublisherStubMock
      |> expect(:list_topics, fn
        (_, %{project: ^project, page_token: ^cursor, page_size: ^max}, _) ->
          {:ok,
            %ListTopicsResponse{topics: topics,
                                next_page_token: cursor}}
      end)
      assert {:ok, [TopicDetails.new(topic), TopicDetails.new(topic)], cursor} ==
        Publisher.topics(client, cursor: cursor, max: max)
    end

    test "error listing topics", %{client: client} do
      error = %RPCError{}
      PublisherStubMock
      |> expect(:list_topics, fn _, _, _ ->
        {:error, error}
      end)
      assert {:error, error} ==
        Publisher.topics(client)
    end
  end

  describe "Publisher.publish/3" do
    setup [:setup_client, :stub_publish, :verify_on_exit!]

    test "successfully publish many messages with data", %{client: client} do
      topic = Util.full_topic(client.project, @topic)
      ids = ["message-1", "message-2"]
      PublisherStubMock
      |> expect(:publish, fn
        (_, %{topic: ^topic}, _) ->
          {:ok, %PublishResponse{message_ids: ids}}
      end)
      assert :ok ==
        Publisher.publish(client, ["data-1", "data-2"] , @topic)
    end

    test "successfully publish a single message with data", %{client: client} do
      topic = Util.full_topic(client.project, @topic)
      ids = ["message-1"]
      PublisherStubMock
      |> expect(:publish, fn
        (_, %{topic: ^topic}, _) ->
          {:ok, %PublishResponse{message_ids: ids}}
      end)
      assert :ok ==
        Publisher.publish(client, "data", @topic)
    end

    test "successfully publish a single message with attributes and data", %{client: client} do
      topic = Util.full_topic(client.project, @topic)
      ids = ["message-1"]
      PublisherStubMock
      |> expect(:publish, fn
        (_, %{topic: ^topic}, _) ->
          {:ok, %PublishResponse{message_ids: ids}}
      end)
      assert :ok ==
        Publisher.publish(client, {"data", %{"foo" => "bar"}}, @topic)
    end

    test "successfully publish a single message with attributes", %{client: client} do
      topic = Util.full_topic(client.project, @topic)
      ids = ["message-1"]
      PublisherStubMock
      |> expect(:publish, fn
        (_, %{topic: ^topic}, _) ->
          {:ok, %PublishResponse{message_ids: ids}}
      end)
      assert :ok ==
        Publisher.publish(client, %{"foo" => "bar"}, @topic)
    end

    test "error publishing messages", %{client: client} do
      error = %RPCError{}
      PublisherStubMock
      |> expect(:publish, fn _, _, _ ->
          {:error, error}
      end)
      assert {:error, error} ==
        Publisher.publish(client, ["data-1", "data-2"], @topic)
    end
  end

  defp setup_client(_) do
    [client: %Client{project: @project}]
  end

  defp stub_create_topic(_) do
    PublisherStubMock
    |> stub(:create_topic, fn _, _, _ ->
      {:ok, %Topic{}}
    end)
    :ok
  end

  defp stub_delete_topic(_) do
    PublisherStubMock
    |> stub(:delete_topic, fn _, _, _ ->
      {:ok, %Empty{}}
    end)
    :ok
  end

  defp stub_list_topics(_) do
    PublisherStubMock
    |> stub(:list_topics, fn _, _, _ ->
      {:ok, %ListTopicsResponse{}}
    end)
    :ok
  end

  defp stub_publish(_) do
    PublisherStubMock
    |> stub(:publish, fn _, _, _ ->
      {:ok, %PublishResponse{}}
    end)
    :ok
  end
end
