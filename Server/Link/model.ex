
defmodule Link do

  # === Read Types
  @read_tree          10_000
  @read_screen_name   10
  @read_post          12
  @read_posts         13
  @read_comments      14

  def raw! user_id, [type, a, b] do
    In.dev!

    args     = [user_id, type, a, b]
    sql_args = Megauni.SQL.to_dollar_num_binary args

    Megauni.SQL.query( "SELECT * FROM link_read(#{sql_args});", args)
    |> Megauni.SQL.one_row("link")
  end

  def create user_id, [type, a, b]  do
    args     = [user_id, type, a, b]
    sql_args = Megauni.SQL.to_dollar_num_binary args

    result = Megauni.SQL.query( "SELECT * FROM link_insert( #{sql_args} );", args)
    |> Megauni.SQL.one_row("link")

    case result do
      {:ok, %{"id"=>_id}} ->
        {:ok, true}

      {:error, {:user_error, "link: already_taken"}} ->
        {:ok, true}

      _ ->
        result
    end
  end # === def create

end # === defmodule Link



