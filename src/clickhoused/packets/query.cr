require "big"
require "../client_packet"

module Clickhoused
  module Packets
    OS_USER = Crystal::System::Env.get("USER")
    HOSTNAME = System.hostname

    class Query < ClientPacket
      property id : String
      property client_name : String
      property client_version : Version
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

      def encode(writer : Writer, revision : UInt64)
        writer.write_string(id)

        # Encode client information
        encode_client_info(writer, revision)

        # Encode settings information
        encode_settings(writer, revision)

        if revision >= DBMS_MIN_REVISION_WITH_INTERSERVER_SECRET
          writer.write_string("")
        end

        writer.write_uint64(Protocol::StateComplete)
        writer.write_bool(false) # TODO: Update to allow compression
        writer.write_string(body)

        if revision >= DBMS_MIN_PROTOCOL_VERSION_WITH_PARAMETERS
          encode_parameters(writer, revision)
        end
      end

      private def encode_client_info(writer : Writer, revision : UInt64)
        writer.write_uint64(Protocol::ClientQueryInitial)
        writer.write_string(initial_user)
        writer.write_string("") # initial_query_id
        writer.write_string(initial_address)

        if revision >= DBMS_MIN_PROTOCOL_VERSION_WITH_INITIAL_QUERY_START_TIME
          writer.write_sfixed64(0) # initial_query_start_time_microseconds
        end

        writer.write_uint64(1_u64) # interface [tcp - 1, http - 2]
        writer.write_string(OS_USER || "")
        writer.write_string(HOSTNAME)
        writer.write_string(client_name)
        writer.write_uint64(client_version.major)
        writer.write_uint64(client_version.minor)
        writer.write_uint64(client_tcp_protocol_version)
        # writer.write_uint64(0_u64)

        if revision >= DBMS_MIN_REVISION_WITH_QUOTA_KEY_IN_CLIENT_INFO
          writer.write_string(quota_key)
        end

        if revision >= DBMS_MIN_PROTOCOL_VERSION_WITH_DISTRIBUTED_DEPTH
          writer.write_uint64(0_u64)
        end

        if revision >= DBMS_MIN_REVISION_WITH_VERSION_PATCH
          writer.write_uint64(0_u64)
        end

        if revision >= DBMS_MIN_REVISION_WITH_OPENTELEMETRY
          # TODO: Pass any opentelemetry span info
          writer.write_byte(0_u8)
        end

        if revision >= DBMS_MIN_REVISION_WITH_PARALLEL_REPLICAS
          writer.write_uint64(0_u64) # collaborate_with_initiator
          writer.write_uint64(0_u64) # count_participating_replicas
          writer.write_uint64(0_u64) # number_of_current_replica
        end
      end

      private def encode_settings(writer : Writer, revision : UInt64)
        settings.each do |setting|
          setting.encode(writer, revision)
        end

        writer.write_string("") # Signal end of settings
      end

      private def encode_parameters(writer : Writer, revision : UInt64)
        parameters.each do |parameter|
          parameter.encode(writer, revision)
        end

        writer.write_string("") # Signal end of parameters
      end
    end

    class Setting
      SETTING_FLAG_IMPORTANT = 0x01
      SETTING_FLAG_CUSTOM = 0x02

      alias ValueType = Time | Bool | Int8 | Int16 | Int32 | Int128 | BigInt | UInt8 | UInt16 | UInt32 | UInt64 | UInt128 | Float32 | Float64 | String | Nil

      property key : String
      property value : ValueType
      property important : Bool
      property custom : Bool

      def initialize(@key, @value, @important = false, @custom = false)
      end

      def encode(writer : Writer, revision : UInt64)
        writer.write_string(key)

        if revision <= DBMS_MIN_REVISION_WITH_SETTINGS_SERIALIZED_AS_STRINGS
          raise "not supported version"
        end

        flags = 0u64

        if important
          flags |= SETTING_FLAG_IMPORTANT
        end

        if custom
          flags |= SETTING_FLAG_CUSTOM
        end

        writer.write_uint64(flags)

        if custom
          raise "custom setting not supported"
          # writer.write_string(value.to_s)
        else
          writer.write_string(value.to_s)
        end
      end
    end

    class Parameter
      property key : String
      property value : String

      def initialize(@key, @value)
      end

      def encode(writer : Writer, revision : UInt64)
        writer.write_string(key)
        writer.write_uint64(2_u64)
        writer.write_string("'#{value.gsub("'", "\\'")}'")
      end
    end
  end
end