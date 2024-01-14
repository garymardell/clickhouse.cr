describe Clickhoused::Columns::BoolColumn, tags: "db" do
  it "supports bools" do
    with_connection do |db|
      db.exec("
        CREATE TABLE test_bool (
            Col1 Bool,
            Col2 Bool
        ) Engine MergeTree() ORDER BY tuple()
      ")

      db.exec("INSERT INTO test_bool (Col1, Col2) VALUES (true, false)")

      db.query("SELECT * FROM test_bool") do |rs|
        rs.each do
          rs.read(Bool).should eq(true)
          rs.read(Bool).should eq(false)
        end
      end
    ensure
      db.exec("DROP TABLE test_bool")
    end
  end
end