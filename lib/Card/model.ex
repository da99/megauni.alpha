
defmodule Card do

  @valid_path_chars      ~r/\A[a-z0-9\_\-\/]+?\Z/
  # raise Invalid.new(self, "Not allowed, /*, because it will grab all pages.")

  @min_code_bytes 1
  @max_code_bytes 2500

  def create( data ) when is_map(data) do
    create(
      data["user_id"],
      data["owner_screen_name"],
      data["privacy"],
      data["code"]
    )
  end # === def create

  def create user_id, owner_screen_name, privacy, raw_code do
    Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      "SELECT id FROM card_insert($1, $2, $3, $4);",
      [
        user_id,
        owner_screen_name,
        privacy,
        Poison.encode!(raw_code)
      ]
    )
    |> Megauni.Model.one_row("card")
  end # === def create

end # === defmodule Card







