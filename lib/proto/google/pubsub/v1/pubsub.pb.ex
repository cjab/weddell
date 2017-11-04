defmodule Google_Pubsub_V1.Topic do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    name:   String.t,
    labels: %{String.t => String.t}
  }
  defstruct [:name, :labels]

  field :name, 1, type: :string
  field :labels, 2, repeated: true, type: Google_Pubsub_V1.Topic.LabelsEntry, map: true
end

defmodule Google_Pubsub_V1.Topic.LabelsEntry do
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
    key:   String.t,
    value: String.t
  }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Google_Pubsub_V1.PubsubMessage do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    data:         String.t,
    attributes:   %{String.t => String.t},
    message_id:   String.t,
    publish_time: Google_Protobuf.Timestamp.t
  }
  defstruct [:data, :attributes, :message_id, :publish_time]

  field :data, 1, type: :bytes
  field :attributes, 2, repeated: true, type: Google_Pubsub_V1.PubsubMessage.AttributesEntry, map: true
  field :message_id, 3, type: :string
  field :publish_time, 4, type: Google_Protobuf.Timestamp
end

defmodule Google_Pubsub_V1.PubsubMessage.AttributesEntry do
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
    key:   String.t,
    value: String.t
  }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Google_Pubsub_V1.GetTopicRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    topic: String.t
  }
  defstruct [:topic]

  field :topic, 1, type: :string
end

defmodule Google_Pubsub_V1.UpdateTopicRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    topic:       Google_Pubsub_V1.Topic.t,
    update_mask: Google_Protobuf.FieldMask.t
  }
  defstruct [:topic, :update_mask]

  field :topic, 1, type: Google_Pubsub_V1.Topic
  field :update_mask, 2, type: Google_Protobuf.FieldMask
end

defmodule Google_Pubsub_V1.PublishRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    topic:    String.t,
    messages: [Google_Pubsub_V1.PubsubMessage.t]
  }
  defstruct [:topic, :messages]

  field :topic, 1, type: :string
  field :messages, 2, repeated: true, type: Google_Pubsub_V1.PubsubMessage
end

defmodule Google_Pubsub_V1.PublishResponse do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    message_ids: [String.t]
  }
  defstruct [:message_ids]

  field :message_ids, 1, repeated: true, type: :string
end

defmodule Google_Pubsub_V1.ListTopicsRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    project:    String.t,
    page_size:  integer,
    page_token: String.t
  }
  defstruct [:project, :page_size, :page_token]

  field :project, 1, type: :string
  field :page_size, 2, type: :int32
  field :page_token, 3, type: :string
end

defmodule Google_Pubsub_V1.ListTopicsResponse do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    topics:          [Google_Pubsub_V1.Topic.t],
    next_page_token: String.t
  }
  defstruct [:topics, :next_page_token]

  field :topics, 1, repeated: true, type: Google_Pubsub_V1.Topic
  field :next_page_token, 2, type: :string
end

defmodule Google_Pubsub_V1.ListTopicSubscriptionsRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    topic:      String.t,
    page_size:  integer,
    page_token: String.t
  }
  defstruct [:topic, :page_size, :page_token]

  field :topic, 1, type: :string
  field :page_size, 2, type: :int32
  field :page_token, 3, type: :string
end

defmodule Google_Pubsub_V1.ListTopicSubscriptionsResponse do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscriptions:   [String.t],
    next_page_token: String.t
  }
  defstruct [:subscriptions, :next_page_token]

  field :subscriptions, 1, repeated: true, type: :string
  field :next_page_token, 2, type: :string
end

defmodule Google_Pubsub_V1.DeleteTopicRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    topic: String.t
  }
  defstruct [:topic]

  field :topic, 1, type: :string
end

defmodule Google_Pubsub_V1.Subscription do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    name:                       String.t,
    topic:                      String.t,
    push_config:                Google_Pubsub_V1.PushConfig.t,
    ack_deadline_seconds:       integer,
    retain_acked_messages:      boolean,
    message_retention_duration: Google_Protobuf.Duration.t,
    labels:                     %{String.t => String.t}
  }
  defstruct [:name, :topic, :push_config, :ack_deadline_seconds, :retain_acked_messages, :message_retention_duration, :labels]

  field :name, 1, type: :string
  field :topic, 2, type: :string
  field :push_config, 4, type: Google_Pubsub_V1.PushConfig
  field :ack_deadline_seconds, 5, type: :int32
  field :retain_acked_messages, 7, type: :bool
  field :message_retention_duration, 8, type: Google_Protobuf.Duration
  field :labels, 9, repeated: true, type: Google_Pubsub_V1.Subscription.LabelsEntry, map: true
end

defmodule Google_Pubsub_V1.Subscription.LabelsEntry do
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
    key:   String.t,
    value: String.t
  }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Google_Pubsub_V1.PushConfig do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    push_endpoint: String.t,
    attributes:    %{String.t => String.t}
  }
  defstruct [:push_endpoint, :attributes]

  field :push_endpoint, 1, type: :string
  field :attributes, 2, repeated: true, type: Google_Pubsub_V1.PushConfig.AttributesEntry, map: true
end

defmodule Google_Pubsub_V1.PushConfig.AttributesEntry do
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
    key:   String.t,
    value: String.t
  }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Google_Pubsub_V1.ReceivedMessage do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    ack_id:  String.t,
    message: Google_Pubsub_V1.PubsubMessage.t
  }
  defstruct [:ack_id, :message]

  field :ack_id, 1, type: :string
  field :message, 2, type: Google_Pubsub_V1.PubsubMessage
end

defmodule Google_Pubsub_V1.GetSubscriptionRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription: String.t
  }
  defstruct [:subscription]

  field :subscription, 1, type: :string
end

defmodule Google_Pubsub_V1.UpdateSubscriptionRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription: Google_Pubsub_V1.Subscription.t,
    update_mask:  Google_Protobuf.FieldMask.t
  }
  defstruct [:subscription, :update_mask]

  field :subscription, 1, type: Google_Pubsub_V1.Subscription
  field :update_mask, 2, type: Google_Protobuf.FieldMask
end

defmodule Google_Pubsub_V1.ListSubscriptionsRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    project:    String.t,
    page_size:  integer,
    page_token: String.t
  }
  defstruct [:project, :page_size, :page_token]

  field :project, 1, type: :string
  field :page_size, 2, type: :int32
  field :page_token, 3, type: :string
end

defmodule Google_Pubsub_V1.ListSubscriptionsResponse do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscriptions:   [Google_Pubsub_V1.Subscription.t],
    next_page_token: String.t
  }
  defstruct [:subscriptions, :next_page_token]

  field :subscriptions, 1, repeated: true, type: Google_Pubsub_V1.Subscription
  field :next_page_token, 2, type: :string
end

defmodule Google_Pubsub_V1.DeleteSubscriptionRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription: String.t
  }
  defstruct [:subscription]

  field :subscription, 1, type: :string
end

defmodule Google_Pubsub_V1.ModifyPushConfigRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription: String.t,
    push_config:  Google_Pubsub_V1.PushConfig.t
  }
  defstruct [:subscription, :push_config]

  field :subscription, 1, type: :string
  field :push_config, 2, type: Google_Pubsub_V1.PushConfig
end

defmodule Google_Pubsub_V1.PullRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription:       String.t,
    return_immediately: boolean,
    max_messages:       integer
  }
  defstruct [:subscription, :return_immediately, :max_messages]

  field :subscription, 1, type: :string
  field :return_immediately, 2, type: :bool
  field :max_messages, 3, type: :int32
end

defmodule Google_Pubsub_V1.PullResponse do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    received_messages: [Google_Pubsub_V1.ReceivedMessage.t]
  }
  defstruct [:received_messages]

  field :received_messages, 1, repeated: true, type: Google_Pubsub_V1.ReceivedMessage
end

defmodule Google_Pubsub_V1.ModifyAckDeadlineRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription:         String.t,
    ack_ids:              [String.t],
    ack_deadline_seconds: integer
  }
  defstruct [:subscription, :ack_ids, :ack_deadline_seconds]

  field :subscription, 1, type: :string
  field :ack_ids, 4, repeated: true, type: :string
  field :ack_deadline_seconds, 3, type: :int32
end

defmodule Google_Pubsub_V1.AcknowledgeRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription: String.t,
    ack_ids:      [String.t]
  }
  defstruct [:subscription, :ack_ids]

  field :subscription, 1, type: :string
  field :ack_ids, 2, repeated: true, type: :string
end

defmodule Google_Pubsub_V1.StreamingPullRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription:                String.t,
    ack_ids:                     [String.t],
    modify_deadline_seconds:     [integer],
    modify_deadline_ack_ids:     [String.t],
    stream_ack_deadline_seconds: integer
  }
  defstruct [:subscription, :ack_ids, :modify_deadline_seconds, :modify_deadline_ack_ids, :stream_ack_deadline_seconds]

  field :subscription, 1, type: :string
  field :ack_ids, 2, repeated: true, type: :string
  field :modify_deadline_seconds, 3, repeated: true, type: :int32
  field :modify_deadline_ack_ids, 4, repeated: true, type: :string
  field :stream_ack_deadline_seconds, 5, type: :int32
end

defmodule Google_Pubsub_V1.StreamingPullResponse do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    received_messages: [Google_Pubsub_V1.ReceivedMessage.t]
  }
  defstruct [:received_messages]

  field :received_messages, 1, repeated: true, type: Google_Pubsub_V1.ReceivedMessage
end

defmodule Google_Pubsub_V1.CreateSnapshotRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    name:         String.t,
    subscription: String.t
  }
  defstruct [:name, :subscription]

  field :name, 1, type: :string
  field :subscription, 2, type: :string
end

defmodule Google_Pubsub_V1.UpdateSnapshotRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    snapshot:    Google_Pubsub_V1.Snapshot.t,
    update_mask: Google_Protobuf.FieldMask.t
  }
  defstruct [:snapshot, :update_mask]

  field :snapshot, 1, type: Google_Pubsub_V1.Snapshot
  field :update_mask, 2, type: Google_Protobuf.FieldMask
end

defmodule Google_Pubsub_V1.Snapshot do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    name:        String.t,
    topic:       String.t,
    expire_time: Google_Protobuf.Timestamp.t,
    labels:      %{String.t => String.t}
  }
  defstruct [:name, :topic, :expire_time, :labels]

  field :name, 1, type: :string
  field :topic, 2, type: :string
  field :expire_time, 3, type: Google_Protobuf.Timestamp
  field :labels, 4, repeated: true, type: Google_Pubsub_V1.Snapshot.LabelsEntry, map: true
end

defmodule Google_Pubsub_V1.Snapshot.LabelsEntry do
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
    key:   String.t,
    value: String.t
  }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Google_Pubsub_V1.ListSnapshotsRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    project:    String.t,
    page_size:  integer,
    page_token: String.t
  }
  defstruct [:project, :page_size, :page_token]

  field :project, 1, type: :string
  field :page_size, 2, type: :int32
  field :page_token, 3, type: :string
end

defmodule Google_Pubsub_V1.ListSnapshotsResponse do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    snapshots:       [Google_Pubsub_V1.Snapshot.t],
    next_page_token: String.t
  }
  defstruct [:snapshots, :next_page_token]

  field :snapshots, 1, repeated: true, type: Google_Pubsub_V1.Snapshot
  field :next_page_token, 2, type: :string
end

defmodule Google_Pubsub_V1.DeleteSnapshotRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    snapshot: String.t
  }
  defstruct [:snapshot]

  field :snapshot, 1, type: :string
end

defmodule Google_Pubsub_V1.SeekRequest do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription: String.t,
    time:         Google_Protobuf.Timestamp.t,
    snapshot:     String.t
  }
  defstruct [:subscription, :time, :snapshot]

  field :subscription, 1, type: :string
  field :time, 2, type: Google_Protobuf.Timestamp
  field :snapshot, 3, type: :string
end

defmodule Google_Pubsub_V1.SeekResponse do
  use Protobuf, syntax: :proto3

  defstruct []

end

defmodule Google_Pubsub_V1.Subscriber.Service do
  use GRPC.Service, name: "google.pubsub.v1.Subscriber"

  rpc :CreateSubscription, Google_Pubsub_V1.Subscription, Google_Pubsub_V1.Subscription
  rpc :GetSubscription, Google_Pubsub_V1.GetSubscriptionRequest, Google_Pubsub_V1.Subscription
  rpc :UpdateSubscription, Google_Pubsub_V1.UpdateSubscriptionRequest, Google_Pubsub_V1.Subscription
  rpc :ListSubscriptions, Google_Pubsub_V1.ListSubscriptionsRequest, Google_Pubsub_V1.ListSubscriptionsResponse
  rpc :DeleteSubscription, Google_Pubsub_V1.DeleteSubscriptionRequest, Google_Protobuf.Empty
  rpc :ModifyAckDeadline, Google_Pubsub_V1.ModifyAckDeadlineRequest, Google_Protobuf.Empty
  rpc :Acknowledge, Google_Pubsub_V1.AcknowledgeRequest, Google_Protobuf.Empty
  rpc :Pull, Google_Pubsub_V1.PullRequest, Google_Pubsub_V1.PullResponse
  rpc :StreamingPull, stream(Google_Pubsub_V1.StreamingPullRequest), stream(Google_Pubsub_V1.StreamingPullResponse)
  rpc :ModifyPushConfig, Google_Pubsub_V1.ModifyPushConfigRequest, Google_Protobuf.Empty
  rpc :ListSnapshots, Google_Pubsub_V1.ListSnapshotsRequest, Google_Pubsub_V1.ListSnapshotsResponse
  rpc :CreateSnapshot, Google_Pubsub_V1.CreateSnapshotRequest, Google_Pubsub_V1.Snapshot
  rpc :UpdateSnapshot, Google_Pubsub_V1.UpdateSnapshotRequest, Google_Pubsub_V1.Snapshot
  rpc :DeleteSnapshot, Google_Pubsub_V1.DeleteSnapshotRequest, Google_Protobuf.Empty
  rpc :Seek, Google_Pubsub_V1.SeekRequest, Google_Pubsub_V1.SeekResponse
end

defmodule Google_Pubsub_V1.Subscriber.Stub do
  use GRPC.Stub, service: Google_Pubsub_V1.Subscriber.Service
end

defmodule Google_Pubsub_V1.Publisher.Service do
  use GRPC.Service, name: "google.pubsub.v1.Publisher"

  rpc :CreateTopic, Google_Pubsub_V1.Topic, Google_Pubsub_V1.Topic
  rpc :UpdateTopic, Google_Pubsub_V1.UpdateTopicRequest, Google_Pubsub_V1.Topic
  rpc :Publish, Google_Pubsub_V1.PublishRequest, Google_Pubsub_V1.PublishResponse
  rpc :GetTopic, Google_Pubsub_V1.GetTopicRequest, Google_Pubsub_V1.Topic
  rpc :ListTopics, Google_Pubsub_V1.ListTopicsRequest, Google_Pubsub_V1.ListTopicsResponse
  rpc :ListTopicSubscriptions, Google_Pubsub_V1.ListTopicSubscriptionsRequest, Google_Pubsub_V1.ListTopicSubscriptionsResponse
  rpc :DeleteTopic, Google_Pubsub_V1.DeleteTopicRequest, Google_Protobuf.Empty
end

defmodule Google_Pubsub_V1.Publisher.Stub do
  use GRPC.Stub, service: Google_Pubsub_V1.Publisher.Service
end
