describe Clickhoused::Columns::FixedStringColumn, tags: "db" do
  it "supports fixed string" do
    with_connection do |db|
      db.exec("
        CREATE TABLE test_fixed_string (
            Col1 FixedString(16),
            Col2 FixedString(16),
            Col3 Nullable(FixedString(32))
        ) Engine MergeTree() ORDER BY tuple()
      ")

      db.exec("INSERT INTO test_fixed_string (Col1, Col2, Col3) VALUES ('abcdefghijklmnop', 'abcdefg', null)")

      db.query("SELECT * FROM test_fixed_string") do |rs|
        rs.each do
          rs.read(String).should eq("abcdefghijklmnop")
          rs.read(String).should eq("abcdefg\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000")
          rs.read(String?).should be_nil
        end
      end
    ensure
      db.exec("DROP TABLE test_fixed_string")
    end
  end
end