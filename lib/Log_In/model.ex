
defmodule Log_In do

  def reset_all do
    {:ok, _} = Ecto.Adapters.SQL.query(
      Megauni.Repos.Main, " DELETE FROM log_in; ", []
    );
  end # === def reset_all

  def attempt data do
    ip   = Map.fetch!(data, "ip")
    sn   = Map.fetch!(data, "screen_name")
    pass = Map.fetch!(data, "pass")
    pswd_hash = Comeonin.Bcrypt.hashpwsalt( User.canonize_pass(pass) )

    result = Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      """
        SELECT pswd_hash
        FROM "user"
        WHERE id IN (
          SELECT owner_id FROM screen_name WHERE screen_name = screen_name_canonize($1)
        );
      """,
      [sn]
    );

    case result do
      {:ok, %{:rows => users}} ->
        pswd_hash = if Enum.count(users) == 0 do
          nil
        else
          users |> List.first |> List.first
        end

        result = Ecto.Adapters.SQL.query(
          Megauni.Repos.Main,
          " SELECT * FROM log_in_attempt($1, $2, $3); ",
          [ip, sn, pswd_hash]
        )

        case result do
          %{"error" => _msg} ->
            result
          {:ok, %{:rows=>ids}} ->
            user_id = ids |> List.first |> List.first
            %{"id"=>user_id}
          _ ->
            In.spect result
            %{"error" => "programmer error: during log in attempt"}
        end # === case

      _ ->
        In.spect(result)
        raise "programmer error: error in searching for user of screen name"
    end

  end # === def attempt

end # === defmodule Log_In

