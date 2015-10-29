
defmodule Link do

  # === Read Types
  @read_tree          10_000
  @read_screen_name   10
  @read_post          12
  @read_posts         13
  @read_comments      14

  def create raw_data do
    Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      "SELECT * FROM link_insert($1, $2, $3, $4);",
      [
        raw_data["type"],
        raw_data["owner_id"],
        raw_data["a_id"],
        raw_data["b_id"],
      ]
    )
    |> Megauni.Model.one_row("card")
  end # === def create

end # === defmodule Link



