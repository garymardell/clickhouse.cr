module Clickhouse
  module Protocol
    OS_USER = Crystal::System::Env.get("USER")
    HOSTNAME = System.hostname

    struct Query
      property id : String
      property client_name : String
      property client_version : Protocol::Version
      property client_tcp_protocol_version : UInt64
      property body : String
      property quota_key : String
      property settings : Array(Setting)
      property parameters : Array(Parameter)
      property compression : Bool
      property initial_user : String
      property initial_address : String

      def initialize(
        @id,
        @client_name,
        @client_version,
        @client_tcp_protocol_version,
        @body,
        @quota_key,
        @compression,
        @initial_user,
        @initial_address,
        @settings = [] of Setting,
        @parameters = [] of Parameter,
      )
      end

      def encode(buffer : Buffer, revision : UInt64)
        buffer.write_string(id)

        # Encode client information
        encode_client_info(buffer, revision)

        # Encode settings information
        encode_settings(buffer, revision)

        if revision >= DBMS_MIN_REVISION_WITH_INTERSERVER_SECRET
          buffer.write_string("")
        end

        buffer.write_uint64(Protocol::StateComplete)
        buffer.write_bool(false) # TODO: Update to allow compression
        buffer.write_string(body)

        if revision >= DBMS_MIN_PROTOCOL_VERSION_WITH_PARAMETERS
          encode_parameters(buffer, revision)
        end
      end

      private def encode_client_info(buffer : Buffer, revision : UInt64)
        buffer.write_uint64(Protocol::ClientQueryInitial)
        buffer.write_string(initial_user)
        buffer.write_string("") # initial_query_id
        buffer.write_string(initial_address)

        if revision >= DBMS_MIN_PROTOCOL_VERSION_WITH_INITIAL_QUERY_START_TIME
          buffer.write_sfixed64(0) # initial_query_start_time_microseconds
        end

        buffer.write_uint64(1_u64) # interface [tcp - 1, http - 2]
        buffer.write_string(OS_USER || "")
        buffer.write_string(HOSTNAME)
        buffer.write_string(client_name)
        buffer.write_uint64(client_version.major)
        buffer.write_uint64(client_version.minor)
        buffer.write_uint64(client_tcp_protocol_version)
        # buffer.write_uint64(0_u64)

        if revision >= DBMS_MIN_REVISION_WITH_QUOTA_KEY_IN_CLIENT_INFO
          buffer.write_string(quota_key)
        end

        if revision >= DBMS_MIN_PROTOCOL_VERSION_WITH_DISTRIBUTED_DEPTH
          buffer.write_uint64(0_u64)
        end

        if revision >= DBMS_MIN_REVISION_WITH_VERSION_PATCH
          buffer.write_uint64(0_u64)
        end

        if revision >= DBMS_MIN_REVISION_WITH_OPENTELEMETRY
          # TODO: Pass any opentelemetry span info
          buffer.write_byte(0_u8)
        end

        if revision >= DBMS_MIN_REVISION_WITH_PARALLEL_REPLICAS
          buffer.write_uint64(0_u64) # collaborate_with_initiator
          buffer.write_uint64(0_u64) # count_participating_replicas
          buffer.write_uint64(0_u64) # number_of_current_replica
        end
      end

      private def encode_settings(buffer : Buffer, revision : UInt64)
        settings.each do |setting|
          setting.encode(buffer, revision)
        end

        buffer.write_string("") # Signal end of settings
      end

      private def encode_parameters(buffer : Buffer, revision : UInt64)
        parameters.each do |parameter|
          parameter.encode(buffer, revision)
        end

        buffer.write_string("") # Signal end of parameters
      end
    end
  end
end