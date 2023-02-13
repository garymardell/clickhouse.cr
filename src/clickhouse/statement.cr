require "uuid"

module Clickhouse
  class Statement < ::DB::Statement
    protected def conn
      connection.as(Connection)
    end

    protected def perform_query(args : Enumerable) : ResultSet
      conn = self.conn
      conn.buffer.write_uint64(Protocol::ClientQuery)

      settings = [
        Protocol::Setting.new("max_execution_time", 60)
      ]
      parameters = [] of Protocol::Parameter

      query = Protocol::Query.new(
        id: UUID.random.to_s,
        client_name: conn.client.name,
        client_version: Protocol::Version.new(
          major: Protocol::ClientVersionMajor,
          minor: Protocol::ClientVersionMinor,
          patch: Protocol::ClientVersionPatch
        ),
        client_tcp_protocol_version: Protocol::ClientTCPProtocolVersion,
        body: command,
        quota_key: "",
        compression: false, # TODO: Support compression,
        initial_user: "",
        initial_address: conn.socket.local_address.to_s,
        settings: settings,
        parameters: parameters
      )

      query.encode(conn.buffer, conn.server.revision)

      send_data(conn, Protocol::Block.new, "")
      conn.flush

      packet = conn.reader.read_byte

      case packet
      when Protocol::ServerEndOfStream
        ResultSet.new(self, nil) # TODO: Indicate that this is empty result set
      when Protocol::ServerData, Protocol::ServerTotals, Protocol::ServerExtremes
        conn.reader.read_string

        block = Protocol::Block.decode(
          conn.reader,
          conn.client.revision,
          packet.not_nil!,
          conn.server.timezone
        )

        pp block

        ResultSet.new(self, block)
      when Protocol::ServerProfileEvents
        ResultSet.new(self, nil)
      when Protocol::ServerProgress
        progress = Protocol::Progress.decode(conn.reader, conn.client.revision)

        # TODO: Do something with the progress? How does this fit with ResultSet.. no idea.
        ResultSet.new(self, nil)
      when Protocol::ServerException
        raise ServerError.new(Protocol::Exception.decode(conn.reader))
      else
        raise Error.new("Unsupported packet #{packet}")
      end
    rescue IO::Error
      raise DB::ConnectionLost.new(connection)
    end

    protected def perform_exec(args : Enumerable) : ::DB::ExecResult
      result = perform_query(args)
      result.each { }

      ::DB::ExecResult.new(
        rows_affected: 0_i64,
        last_insert_id: 0_i64 # postgres doesn't support this
      )
    rescue IO::Error
      raise DB::ConnectionLost.new(connection)
    end

    private def send_data(conn : Connection, block : Protocol::Block, name : String)
      conn.buffer.write_uint64(Protocol::ClientData)
      conn.buffer.write_string(name)

      block.encode_header(conn.buffer, conn.client.revision)

      # TODO: Compression

      # conn.flush
    end

    private def format(arg)
      case arg
      when Time
        "toDateTime(#{arg.to_unix})"
      when Bool
        arg ? "true" : "false"
      when Int8, Int16, Int32, Int64, Int128, BigInt
        arg.to_s
      when UInt8, UInt16, UInt32, UInt64, UInt128
        arg.to_s
      when Float32, Float64
        arg.to_s
      when String
        quote(arg)
      when Nil
        "NULL"
      else
        quote("")
      end
    end

    private def quote(string : String)
      String.build do |io|
        io << "\""
        io << string
        io << "\""
      end
    end
  end
end