
defmodule Log_In do

  def upsert ip, sn, pswd do
    pswd_hash = Comeonin.Bcrypt.hashpwsalt( clean_pass )
    result = Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      """
        SELECT * FROM log_in_upsert($1, $2, $3);
      """,
      [ip, sn, pswd]
    )
    case result do
      %{"error" => _msg} ->
        result
      _ when is_list(result) ->
        List.first(result).user_id
      _ ->
        %{"error" => "programmer error: during log in attempt"}
    end # === case
  end # === def upsert

end # === defmodule Log_In

