

data = File.read! "lib/Screen_Name/specs/01-create.json"
json = Poison.decode! data
IO.inspect(json)

