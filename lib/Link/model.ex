
defmodule Link do

  # === Read Types
  @read_tree          10_000
  @read_screen_name   10
  @read_post          12
  @read_posts         13
  @read_comments      14

  def create user_id, [type, a, b]  do
    args     = [user_id, type, a, b]
    sql_args = Megauni.Model.sql_args args

    result = Megauni.Model.query( "SELECT * FROM link_insert( #{sql_args} );", args)
    |> Megauni.Model.one_row("link")
    case result do
      %{"id"=>_id} ->
        true
      %{"user_error"=> "link: already_taken"} ->
        true
      _ ->
        result
    end
  end # === def create

end # === defmodule Link



