
defmodule Card do

  @valid_path_chars      ~r/\A[a-z0-9\_\-\/]+?\Z/
  # raise Invalid.new(self, "Not allowed, /*, because it will grab all pages.")

  @min_code_bytes 1
  @max_code_bytes 2500

  def create raw_data do
    Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      "SELECT * FROM card_insert($1, $2, $3);",
      [
        raw_data["owner"] || raw_data["owner_id"],
        raw_data["privacy"],
        Poison.encode!(raw_data["code"])
      ]
    )
    |> Megauni.Model.one_row("card")
  end # === def create

end # === defmodule Card







