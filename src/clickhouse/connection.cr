require "socket"
require "http/client"

module Clickhouse
  class Connection < ::DB::Connection
    DBMS_MIN_REVISION_WITH_CLIENT_INFO                        = 54032
    DBMS_MIN_REVISION_WITH_SERVER_TIMEZONE                    = 54058
    DBMS_MIN_REVISION_WITH_QUOTA_KEY_IN_CLIENT_INFO           = 54060
    DBMS_MIN_REVISION_WITH_SERVER_DISPLAY_NAME                = 54372
    DBMS_MIN_REVISION_WITH_VERSION_PATCH                      = 54401
    DBMS_MIN_REVISION_WITH_CLIENT_WRITE_INFO                  = 54420
    DBMS_MIN_REVISION_WITH_SETTINGS_SERIALIZED_AS_STRINGS     = 54429
    DBMS_MIN_REVISION_WITH_INTERSERVER_SECRET                 = 54441
    DBMS_MIN_REVISION_WITH_OPENTELEMETRY                      = 54442
    DBMS_MIN_PROTOCOL_VERSION_WITH_DISTRIBUTED_DEPTH          = 54448
    DBMS_MIN_PROTOCOL_VERSION_WITH_INITIAL_QUERY_START_TIME   = 54449
    DBMS_MIN_PROTOCOL_VERSION_WITH_INCREMENTAL_PROFILE_EVENTS = 54451
    DBMS_MIN_REVISION_WITH_PARALLEL_REPLICAS                  = 54453
    DBMS_MIN_REVISION_WITH_CUSTOM_SERIALIZATION               = 54454
    DBMS_MIN_PROTOCOL_VERSION_WITH_ADDENDUM                   = 54458
    DBMS_MIN_PROTOCOL_VERSION_WITH_QUOTA_KEY                  = 54458
    DBMS_MIN_PROTOCOL_VERSION_WITH_PARAMETERS                 = 54459
    DBMS_TCP_PROTOCOL_VERSION                                 = DBMS_MIN_PROTOCOL_VERSION_WITH_PARAMETERS.to_u64

    protected getter socket : TCPSocket

    property buffer : Buffer
    property reader : Reader
    property client : Clickhouse::Protocol::ClientHandshake
    property server : Clickhouse::Protocol::ServerHandshake

    def initialize(context)
      super(context)

      host = context.uri.hostname || raise "no host provided"
      port = context.uri.port || 9000

      @socket = TCPSocket.new(host, port)
      # @socket.sync = false

      @reader = Reader.new(@socket)
      @buffer = Buffer.new
      @buffer.write_uint64(Protocol::ClientHello)

      @client = Protocol::ClientHandshake.new("Rawr", 54459u64)
      @client.encode(@buffer)

      @buffer.write_string("default") # database
      @buffer.write_string("default") # user
      @buffer.write_string("") # password

      flush

      packet = @reader.read_byte

      case packet
      when Protocol::ServerException
        puts "Server exception"
        # TODO: Read exception error and format an exception
        raise "server exception"
      when Protocol::ServerHello
        puts "Server said hello"
        @server = Protocol::ServerHandshake.decode(@reader)

        if Protocol::ClientTCPProtocolVersion >= Connection::DBMS_MIN_PROTOCOL_VERSION_WITH_ADDENDUM
          if @client.revision >= Connection::DBMS_MIN_PROTOCOL_VERSION_WITH_QUOTA_KEY
            # c.buffer.PutString("") # todo quota key support
            @buffer.write_string("")
          end
        end

        flush

        pp @server
      when Protocol::ServerEndOfStream
        puts "Stream ended"
        # TODO: Exception that connection closed
        raise "Stream ended"
      else
        puts "We got nothing back"
        # TODO: Panic
        raise "got nothing"
      end

      if server.revision < DBMS_MIN_REVISION_WITH_CLIENT_INFO
        raise "Not supported"
      end

      if client.revision > server.revision
        client.revision = server.revision
      end
    end

    def flush
      if buffer.size == 0
        return
      end

      puts "written to socket"
      # puts buffer.to_slice.join(" ")
      puts buffer.to_slice

      # IO.copy buffer, socket, buffer.size
      socket.write(buffer.to_slice)
      socket.flush

      buffer.reset
    end

    def send_query(body : String)
      # c.buffer.PutByte(proto.ClientQuery)

      query = Protocol::Query.new(
        id: "",
        body: body,
        quota_key: "",
        compression: false,
        initial_user: "",
        initial_address: "",
      )

      query.encode(@buffer)

      flush
    end

    def build_prepared_statement(query) : Statement
      Statement.new(self, query)
    end

    def build_unprepared_statement(query) : Statement
      Statement.new(self, query)
    end

    def begin_transaction : ::DB::Transaction
      raise ::DB::Error.new("Transactions are not supported")
    end

    protected def do_close
      super

      begin
        @socket.close
      rescue
      end
    end
  end
end