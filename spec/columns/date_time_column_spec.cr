describe Clickhoused::Columns::DateTimeColumn, tags: "db" do
  it "supports datetime" do
    with_connection do |db|
      db.exec("
        CREATE TABLE test_datetime (
            Col1 DateTime,
        ) Engine MergeTree() ORDER BY tuple()
      ")

      db.exec("INSERT INTO test_datetime (Col1) VALUES ('2019-01-01 00:00:00')")

      db.query("SELECT * FROM test_datetime") do |rs|
        rs.each do
          rs.read(Time).should eq(Time.parse("2019-01-01 00:00:00", "%Y-%m-%d %T", Time::Location::UTC))
        end
      end
    ensure
      db.exec("DROP TABLE test_datetime")
    end
  end
end