require "socket"
require "./writer"
require "./reader"
require "./errors"
require "./query_options"
require "./protocol"
require "./packets/*"

module Clickhoused
  class Connection
    property! revision : UInt64
    property! server : Packets::ServerHello

    def initialize(host, port, database, username, password)
      # We start with a default protocol version that may be downgraded by the server during handshake
      @revision = Protocol::ClientTCPProtocolVersion

      @socket = TCPSocket.new(host, port)
      @writer = Writer.new
      @reader = Reader.new(@socket)

      handshake(database, username, password)

      if revision >= DBMS_MIN_PROTOCOL_VERSION_WITH_ADDENDUM
        send_addendum # TODO: Quote key support
      end
    end

    def handshake(database : String, username : String, password : String)
      @writer.write_uint64(Protocol::ClientHello)

      hello = Packets::ClientHello.new(
        name: "Crystal Client",
        version: Version.new(
          major: Protocol::ClientVersionMajor,
          minor: Protocol::ClientVersionMinor,
          patch: Protocol::ClientVersionPatch
        )
      )
      hello.encode(@writer)

      @writer.write_string(database)
      @writer.write_string(username)
      @writer.write_string(password)

      flush

      case @socket.read_byte
      when Protocol::ServerHello
        @server = Packets::ServerHello.decode(@reader)
      when Protocol::ServerException
        server_exception = Packets::Exception.decode(@reader)
        raise ConnectionError.new(server_exception.message)
      else
        raise ConnectionError.new
      end

      if server.revision < DBMS_MIN_REVISION_WITH_CLIENT_INFO
        raise UnsupportedRevisionError.new("revision must be >= #{DBMS_MIN_REVISION_WITH_CLIENT_INFO} but server responded with #{server.revision}")
      end

      # Downgrade client protocol to match server
      if revision > server.revision
        @revision = server.revision
      end
    end

    def read_packet : ServerPacket
      packet = @reader.read_byte.not_nil!

      case packet
      when Protocol::ServerData
        read_data(Packets::Data, packet, true)
      when Protocol::ServerTotals
        read_data(Packets::Totals, packet, true)
      when Protocol::ServerExtremes
        read_data(Packets::Extremes, packet, true)
      when Protocol::ServerEndOfStream
        Packets::EndOfStream.new
      when Protocol::ServerException
        Packets::Exception.decode(@reader)
      when Protocol::ServerProfileInfo
        Packets::ProfileInfo.decode(@reader)
      when Protocol::ServerTableColumns
        raise PacketNotImplementedError.new
      when Protocol::ServerProfileEvents
        read_data(Packets::ProfileEvents, packet, true)
      when Protocol::ServerLog
        raise PacketNotImplementedError.new
      when Protocol::ServerProgress
        Packets::Progress.decode(@reader, revision)
      when Protocol::ServerPong
        Packets::Pong.new
      else
        raise ConnectionError.new("Unexpected packet #{packet} received")
      end
    end

    def send_query(body : String, options : QueryOptions)
      @writer.write_byte(Protocol::ClientQuery)

      query = Packets::Query.new(
        id: options.query_id,
        client_name: "",
        client_version: Version.new(Protocol::ClientVersionMajor, Protocol::ClientVersionMinor, Protocol::ClientVersionPatch),
        client_tcp_protocol_version: Protocol::ClientTCPProtocolVersion,
        body: body,
        quota_key: "",
        compression: false,
        initial_user: "",
        initial_address: @socket.local_address.to_s
      )

      query.encode(@writer, revision)

      options.external.each do |table|
        send_data(table.block, table.name)
      end

      send_data(Packets::Block.new, "")
      flush
    end

    def send_data(block : Packets::Block, name : String)
      @writer.write_byte(Protocol::ClientData)
      @writer.write_string(name)

      block.encode_header(@writer, revision)
      block.columns.each do |column|
        column.encode(@writer, revision)
      end

      # TODO: Compression
      flush
    ensure
      @writer.reset
    end

    def send_cancel
      @writer.write_byte(ClientCancel)

      flush
    end

    def send_ping
      @socket.write_byte(Protocol::ClientPing)

      flush
    end

    def flush
      if @writer.size == 0
        return
      end

      @socket.write(@writer.to_slice)
      @socket.flush
      @writer.reset
    end

    def read_data(kind : T.class, packet : UInt8, compressible : Bool) forall T
      @reader.read_string

      # TODO: compression

      options = QueryOptions.new # TODO: Do something here
      location = server.timezone

      T.decode(
        reader: @reader,
        revision: revision,
        packet: packet,
        timezone: location
      )
    end

    def close
      @socket.close
    end

    private def send_addendum
      if revision >= DBMS_MIN_PROTOCOL_VERSION_WITH_QUOTA_KEY
        @writer.write_string("")
      end

      flush
    end
  end
end