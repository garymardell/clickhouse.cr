module Clickhouse
  class Statement < ::DB::Statement
    protected def conn
      connection.as(Connection)
    end

    protected def perform_query(args : Enumerable) : ResultSet
      conn.connection.send_query(command, Clickhoused::QueryOptions.new)

      packet = nil
      blocks = [] of Clickhoused::Packets::Data

      until packet.is_a?(Clickhoused::Packets::EndOfStream) || packet.is_a?(Clickhoused::Packets::Exception)
        packet = conn.connection.read_packet


        case packet
        when Clickhoused::Packets::Data
          blocks << packet if packet.rows > 0 # Skip the empty data blocks
        when Clickhoused::Packets::Exception
          raise ::DB::Error.new(packet.message)
        end
      end

      # As Clickhouse is columnar and streams in results we need to consume all data blocks until end of stream to generate the result set. If we deferred to `ResultSet` we would attempt to read row by row.

      ResultSet.new(self, blocks)
    rescue IO::Error | Clickhoused::ConnectionError
      raise DB::ConnectionLost.new(connection)
    end

    protected def perform_exec(args : Enumerable) : ::DB::ExecResult
      result = perform_query(args)
      result.each { }

      ::DB::ExecResult.new(
        rows_affected: 0_i64,
        last_insert_id: 0_i64 # postgres doesn't support this
      )
    rescue IO::Error | Clickhoused::ConnectionError
      raise DB::ConnectionLost.new(connection)
    end
  end
end