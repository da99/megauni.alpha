
defmodule Log_In do

  def attempt data do
    ip   = Map.fetch!(data, "ip")
    sn   = Map.fetch!(data, "screen_name")
    pass = Map.fetch!(data, "pass")
    pswd_hash = Comeonin.Bcrypt.hashpwsalt( pass )
    In.spect pswd_hash
    result = Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      " SELECT * FROM log_in_attempt($1, $2, $3); ",
      [ip, sn, pswd_hash]
    )
    case result do
      %{"error" => _msg} ->
        result
      _ when is_list(result) ->
        List.first(result).user_id
      _ ->
        %{"error" => "programmer error: during log in attempt"}
    end # === case
  end # === def attempt

end # === defmodule Log_In

