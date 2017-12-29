defmodule Google.Pubsub.V1.Topic do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    name:   String.t,
    labels: %{String.t => String.t}
  }
  defstruct [:name, :labels]

  field :name, 1, type: :string
  field :labels, 2, repeated: true, type: Google.Pubsub.V1.Topic.LabelsEntry, map: true
end

defmodule Google.Pubsub.V1.Topic.LabelsEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
    key:   String.t,
    value: String.t
  }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Google.Pubsub.V1.PubsubMessage do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    data:         String.t,
    attributes:   %{String.t => String.t},
    message_id:   String.t,
    publish_time: Google.Protobuf.Timestamp.t
  }
  defstruct [:data, :attributes, :message_id, :publish_time]

  field :data, 1, type: :bytes
  field :attributes, 2, repeated: true, type: Google.Pubsub.V1.PubsubMessage.AttributesEntry, map: true
  field :message_id, 3, type: :string
  field :publish_time, 4, type: Google.Protobuf.Timestamp
end

defmodule Google.Pubsub.V1.PubsubMessage.AttributesEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
    key:   String.t,
    value: String.t
  }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Google.Pubsub.V1.GetTopicRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    topic: String.t
  }
  defstruct [:topic]

  field :topic, 1, type: :string
end

defmodule Google.Pubsub.V1.UpdateTopicRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    topic:       Google.Pubsub.V1.Topic.t,
    update_mask: Google.Protobuf.FieldMask.t
  }
  defstruct [:topic, :update_mask]

  field :topic, 1, type: Google.Pubsub.V1.Topic
  field :update_mask, 2, type: Google.Protobuf.FieldMask
end

defmodule Google.Pubsub.V1.PublishRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    topic:    String.t,
    messages: [Google.Pubsub.V1.PubsubMessage.t]
  }
  defstruct [:topic, :messages]

  field :topic, 1, type: :string
  field :messages, 2, repeated: true, type: Google.Pubsub.V1.PubsubMessage
end

defmodule Google.Pubsub.V1.PublishResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    message_ids: [String.t]
  }
  defstruct [:message_ids]

  field :message_ids, 1, repeated: true, type: :string
end

defmodule Google.Pubsub.V1.ListTopicsRequest do
  @moduledoc false
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

defmodule Google.Pubsub.V1.ListTopicsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    topics:          [Google.Pubsub.V1.Topic.t],
    next_page_token: String.t
  }
  defstruct [:topics, :next_page_token]

  field :topics, 1, repeated: true, type: Google.Pubsub.V1.Topic
  field :next_page_token, 2, type: :string
end

defmodule Google.Pubsub.V1.ListTopicSubscriptionsRequest do
  @moduledoc false
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

defmodule Google.Pubsub.V1.ListTopicSubscriptionsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscriptions:   [String.t],
    next_page_token: String.t
  }
  defstruct [:subscriptions, :next_page_token]

  field :subscriptions, 1, repeated: true, type: :string
  field :next_page_token, 2, type: :string
end

defmodule Google.Pubsub.V1.DeleteTopicRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    topic: String.t
  }
  defstruct [:topic]

  field :topic, 1, type: :string
end

defmodule Google.Pubsub.V1.Subscription do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    name:                       String.t,
    topic:                      String.t,
    push_config:                Google.Pubsub.V1.PushConfig.t,
    ack_deadline_seconds:       integer,
    retain_acked_messages:      boolean,
    message_retention_duration: Google.Protobuf.Duration.t,
    labels:                     %{String.t => String.t}
  }
  defstruct [:name, :topic, :push_config, :ack_deadline_seconds, :retain_acked_messages, :message_retention_duration, :labels]

  field :name, 1, type: :string
  field :topic, 2, type: :string
  field :push_config, 4, type: Google.Pubsub.V1.PushConfig
  field :ack_deadline_seconds, 5, type: :int32
  field :retain_acked_messages, 7, type: :bool
  field :message_retention_duration, 8, type: Google.Protobuf.Duration
  field :labels, 9, repeated: true, type: Google.Pubsub.V1.Subscription.LabelsEntry, map: true
end

defmodule Google.Pubsub.V1.Subscription.LabelsEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
    key:   String.t,
    value: String.t
  }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Google.Pubsub.V1.PushConfig do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    push_endpoint: String.t,
    attributes:    %{String.t => String.t}
  }
  defstruct [:push_endpoint, :attributes]

  field :push_endpoint, 1, type: :string
  field :attributes, 2, repeated: true, type: Google.Pubsub.V1.PushConfig.AttributesEntry, map: true
end

defmodule Google.Pubsub.V1.PushConfig.AttributesEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
    key:   String.t,
    value: String.t
  }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Google.Pubsub.V1.ReceivedMessage do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    ack_id:  String.t,
    message: Google.Pubsub.V1.PubsubMessage.t
  }
  defstruct [:ack_id, :message]

  field :ack_id, 1, type: :string
  field :message, 2, type: Google.Pubsub.V1.PubsubMessage
end

defmodule Google.Pubsub.V1.GetSubscriptionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription: String.t
  }
  defstruct [:subscription]

  field :subscription, 1, type: :string
end

defmodule Google.Pubsub.V1.UpdateSubscriptionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription: Google.Pubsub.V1.Subscription.t,
    update_mask:  Google.Protobuf.FieldMask.t
  }
  defstruct [:subscription, :update_mask]

  field :subscription, 1, type: Google.Pubsub.V1.Subscription
  field :update_mask, 2, type: Google.Protobuf.FieldMask
end

defmodule Google.Pubsub.V1.ListSubscriptionsRequest do
  @moduledoc false
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

defmodule Google.Pubsub.V1.ListSubscriptionsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscriptions:   [Google.Pubsub.V1.Subscription.t],
    next_page_token: String.t
  }
  defstruct [:subscriptions, :next_page_token]

  field :subscriptions, 1, repeated: true, type: Google.Pubsub.V1.Subscription
  field :next_page_token, 2, type: :string
end

defmodule Google.Pubsub.V1.DeleteSubscriptionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription: String.t
  }
  defstruct [:subscription]

  field :subscription, 1, type: :string
end

defmodule Google.Pubsub.V1.ModifyPushConfigRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription: String.t,
    push_config:  Google.Pubsub.V1.PushConfig.t
  }
  defstruct [:subscription, :push_config]

  field :subscription, 1, type: :string
  field :push_config, 2, type: Google.Pubsub.V1.PushConfig
end

defmodule Google.Pubsub.V1.PullRequest do
  @moduledoc false
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

defmodule Google.Pubsub.V1.PullResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    received_messages: [Google.Pubsub.V1.ReceivedMessage.t]
  }
  defstruct [:received_messages]

  field :received_messages, 1, repeated: true, type: Google.Pubsub.V1.ReceivedMessage
end

defmodule Google.Pubsub.V1.ModifyAckDeadlineRequest do
  @moduledoc false
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

defmodule Google.Pubsub.V1.AcknowledgeRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    subscription: String.t,
    ack_ids:      [String.t]
  }
  defstruct [:subscription, :ack_ids]

  field :subscription, 1, type: :string
  field :ack_ids, 2, repeated: true, type: :string
end

defmodule Google.Pubsub.V1.StreamingPullRequest do
  @moduledoc false
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

defmodule Google.Pubsub.V1.StreamingPullResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    received_messages: [Google.Pubsub.V1.ReceivedMessage.t]
  }
  defstruct [:received_messages]

  field :received_messages, 1, repeated: true, type: Google.Pubsub.V1.ReceivedMessage
end

defmodule Google.Pubsub.V1.CreateSnapshotRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    name:         String.t,
    subscription: String.t
  }
  defstruct [:name, :subscription]

  field :name, 1, type: :string
  field :subscription, 2, type: :string
end

defmodule Google.Pubsub.V1.UpdateSnapshotRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    snapshot:    Google.Pubsub.V1.Snapshot.t,
    update_mask: Google.Protobuf.FieldMask.t
  }
  defstruct [:snapshot, :update_mask]

  field :snapshot, 1, type: Google.Pubsub.V1.Snapshot
  field :update_mask, 2, type: Google.Protobuf.FieldMask
end

defmodule Google.Pubsub.V1.Snapshot do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    name:        String.t,
    topic:       String.t,
    expire_time: Google.Protobuf.Timestamp.t,
    labels:      %{String.t => String.t}
  }
  defstruct [:name, :topic, :expire_time, :labels]

  field :name, 1, type: :string
  field :topic, 2, type: :string
  field :expire_time, 3, type: Google.Protobuf.Timestamp
  field :labels, 4, repeated: true, type: Google.Pubsub.V1.Snapshot.LabelsEntry, map: true
end

defmodule Google.Pubsub.V1.Snapshot.LabelsEntry do
  @moduledoc false
  use Protobuf, map: true, syntax: :proto3

  @type t :: %__MODULE__{
    key:   String.t,
    value: String.t
  }
  defstruct [:key, :value]

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Google.Pubsub.V1.ListSnapshotsRequest do
  @moduledoc false
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

defmodule Google.Pubsub.V1.ListSnapshotsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    snapshots:       [Google.Pubsub.V1.Snapshot.t],
    next_page_token: String.t
  }
  defstruct [:snapshots, :next_page_token]

  field :snapshots, 1, repeated: true, type: Google.Pubsub.V1.Snapshot
  field :next_page_token, 2, type: :string
end

defmodule Google.Pubsub.V1.DeleteSnapshotRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    snapshot: String.t
  }
  defstruct [:snapshot]

  field :snapshot, 1, type: :string
end

defmodule Google.Pubsub.V1.SeekRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    target:       {atom, any},
    subscription: String.t
  }
  defstruct [:target, :subscription]

  oneof :target, 0
  field :subscription, 1, type: :string
  field :time, 2, type: Google.Protobuf.Timestamp, oneof: 0
  field :snapshot, 3, type: :string, oneof: 0
end

defmodule Google.Pubsub.V1.SeekResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  defstruct []

end

defmodule Google.Pubsub.V1.Subscriber.Service do
  @moduledoc false
  use GRPC.Service, name: "google.pubsub.v1.Subscriber"

  rpc :CreateSubscription, Google.Pubsub.V1.Subscription, Google.Pubsub.V1.Subscription
  rpc :GetSubscription, Google.Pubsub.V1.GetSubscriptionRequest, Google.Pubsub.V1.Subscription
  rpc :UpdateSubscription, Google.Pubsub.V1.UpdateSubscriptionRequest, Google.Pubsub.V1.Subscription
  rpc :ListSubscriptions, Google.Pubsub.V1.ListSubscriptionsRequest, Google.Pubsub.V1.ListSubscriptionsResponse
  rpc :DeleteSubscription, Google.Pubsub.V1.DeleteSubscriptionRequest, Google.Protobuf.Empty
  rpc :ModifyAckDeadline, Google.Pubsub.V1.ModifyAckDeadlineRequest, Google.Protobuf.Empty
  rpc :Acknowledge, Google.Pubsub.V1.AcknowledgeRequest, Google.Protobuf.Empty
  rpc :Pull, Google.Pubsub.V1.PullRequest, Google.Pubsub.V1.PullResponse
  rpc :StreamingPull, stream(Google.Pubsub.V1.StreamingPullRequest), stream(Google.Pubsub.V1.StreamingPullResponse)
  rpc :ModifyPushConfig, Google.Pubsub.V1.ModifyPushConfigRequest, Google.Protobuf.Empty
  rpc :ListSnapshots, Google.Pubsub.V1.ListSnapshotsRequest, Google.Pubsub.V1.ListSnapshotsResponse
  rpc :CreateSnapshot, Google.Pubsub.V1.CreateSnapshotRequest, Google.Pubsub.V1.Snapshot
  rpc :UpdateSnapshot, Google.Pubsub.V1.UpdateSnapshotRequest, Google.Pubsub.V1.Snapshot
  rpc :DeleteSnapshot, Google.Pubsub.V1.DeleteSnapshotRequest, Google.Protobuf.Empty
  rpc :Seek, Google.Pubsub.V1.SeekRequest, Google.Pubsub.V1.SeekResponse
end

defmodule Google.Pubsub.V1.Subscriber.Stub do
  @moduledoc false
  use GRPC.Stub, service: Google.Pubsub.V1.Subscriber.Service
end

defmodule Google.Pubsub.V1.Publisher.Service do
  @moduledoc false
  use GRPC.Service, name: "google.pubsub.v1.Publisher"

  rpc :CreateTopic, Google.Pubsub.V1.Topic, Google.Pubsub.V1.Topic
  rpc :UpdateTopic, Google.Pubsub.V1.UpdateTopicRequest, Google.Pubsub.V1.Topic
  rpc :Publish, Google.Pubsub.V1.PublishRequest, Google.Pubsub.V1.PublishResponse
  rpc :GetTopic, Google.Pubsub.V1.GetTopicRequest, Google.Pubsub.V1.Topic
  rpc :ListTopics, Google.Pubsub.V1.ListTopicsRequest, Google.Pubsub.V1.ListTopicsResponse
  rpc :ListTopicSubscriptions, Google.Pubsub.V1.ListTopicSubscriptionsRequest, Google.Pubsub.V1.ListTopicSubscriptionsResponse
  rpc :DeleteTopic, Google.Pubsub.V1.DeleteTopicRequest, Google.Protobuf.Empty
end

defmodule Google.Pubsub.V1.Publisher.Stub do
  @moduledoc false
  use GRPC.Stub, service: Google.Pubsub.V1.Publisher.Service
end
