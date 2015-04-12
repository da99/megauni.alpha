
describe :it_runs do

  it "runs" do
    asql Link::SQL[:post].to_sql
    fail
  end # === it

end # === describe :it_runs
