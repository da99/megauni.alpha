
defmodule Link do

  # === Read Types
  @read_tree          10_000
  @read_screen_name   10
  @read_post          12
  @read_posts         13
  @read_comments      14

  def create user_id, [type, a, b]  do
    Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      "SELECT * FROM link_insert($1, $2, $3, $4);",
      [
        user_id,
        type,
        a,
        b
      ]
    )
    |> Megauni.Model.one_row("link")
  end # === def create

end # === defmodule Link



