require "socket"
require "http/client"

module Clickhouse
  class Connection < ::DB::Connection
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
        raise ServerError.new(Protocol::Exception.decode(@reader))
      when Protocol::ServerHello
        puts "Server said hello"
        @server = Protocol::ServerHandshake.decode(@reader)

        if Protocol::ClientTCPProtocolVersion >= DBMS_MIN_PROTOCOL_VERSION_WITH_ADDENDUM
          if @client.revision >= DBMS_MIN_PROTOCOL_VERSION_WITH_QUOTA_KEY
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

      socket.write(buffer.to_slice)
      socket.flush

      buffer.reset
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