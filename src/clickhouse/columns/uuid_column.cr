module Clickhouse
  module Columns
    class UUIDColumn < Column
      def decode(reader : Reader, rows : UInt64)
      end
    end
  end
end