
defmodule Log_In do

  def reset_all do
    {:ok, _} = Ecto.Adapters.SQL.query(
      Megauni.Repos.Main, " DELETE FROM log_in; ", []
    );
  end # === def reset_all

  @doc """
    This is made complicated because we are hashing the pass phrase
    before sending it to the DB, to ensure raw pass phrase from traveling
    as little as possible throught the network/system.
  """
  def attempt data do
    ip   = Map.fetch!(data, "ip")
    sn   = Map.fetch!(data, "screen_name")
    pass = User.canonize_pass Map.fetch!(data, "pass")

    user = Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      """
        SELECT "user".id, "user".pswd_hash, "screen_name".id AS sn_id
        FROM "user", screen_name
        WHERE
          "screen_name".owner_id = "user".id
          AND
          "screen_name".screen_name = screen_name_canonize($1)
        ;
      """,
      [sn]
    );

    user_id    = nil
    sn_id      = nil
    pass_match = false

    case user do
      {:ok, %{:rows => users}} ->
        if Enum.count(users) > 0 do
          [[user_id, valid_pswd_hash, sn_id]] = users
          pass_match                          = Comeonin.Bcrypt.checkpw pass, valid_pswd_hash
        end

      _ ->
        In.spect user
        raise "programmer or system error"
    end

    result = Ecto.Adapters.SQL.query(
      Megauni.Repos.Main,
      " SELECT * FROM log_in_attempt($1, $2, $3, $4); ",
      [ip, sn_id, user_id, pass_match]
    )

    case result do
      %{"error" => _msg} ->
        result
      {:ok, %{:rows=>[[true]]}} ->
        %{"id"=>user_id}
      _ ->
        In.spect result
        %{"error" => "programmer error: during log in attempt"}
    end # === case

  end # === def attempt

end # === defmodule Log_In

