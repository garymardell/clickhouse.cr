module Clickhouse
  module Columns
    class StringColumn < Column
      def decode(reader : Reader, rows : UInt64)
        rows.times do
          pp reader.read_string
        end
      end
    end
  end
end


# var p Position
# 	for i := 0; i < rows; i++ {
# 		n, err := r.StrLen()
# 		if err != nil {
# 			return errors.Wrapf(err, "row %d: read length", i)
# 		}

# 		p.Start = p.End
# 		p.End += n

# 		c.Buf = append(c.Buf, make([]byte, n)...)
# 		if err := r.ReadFull(c.Buf[p.Start:p.End]); err != nil {
# 			return errors.Wrapf(err, "row %d: read full", i)
# 		}
# 		c.Pos = append(c.Pos, p)
# 	}
# 	return nil