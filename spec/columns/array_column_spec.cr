describe Clickhoused::Columns::ArrayColumn, tags: "db" do
  it "supports arrays" do
    with_connection do |db|
      db.exec("
        CREATE TABLE test_array (
            Col1 Array(String)
        ) Engine MergeTree() ORDER BY tuple()
      ")

      db.exec("INSERT INTO test_array (Col1) VALUES (['a', 'b'])")

      db.query("SELECT * FROM test_array") do |rs|
        rs.each do
          rs.read(Array(String)).should eq(["a", "b"])
        end
      end
    ensure
      db.exec("DROP TABLE test_array")
    end
  end
end