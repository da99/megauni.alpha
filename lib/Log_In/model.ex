
defmodule Log_In do

  def reset_all do
    {:ok, _} = Megauni.SQL.query("DELETE FROM log_in;", []);
  end # === def reset_all

  def aged str do
    if !In.dev do
      raise "Only to be used in dev"
    end
    Megauni.SQL.query(
      """
        UPDATE log_in
        SET at = at + '#{str}'::interval
      """,
      []
    );
  end

  @doc """
    This is made complicated because we are hashing the pass phrase
    before sending it to the DB, to ensure raw pass phrase from traveling
    as little as possible throught the network/system.
  """
  def attempt %{"ip"=>ip, "screen_name"=>sn, "pass"=>raw_pass} do
    pass = raw_pass |> User.canonize_pass

    user = Megauni.SQL.query(
      """
        SELECT "user".id, "user".pswd_hash, "screen_name".id AS sn_id
        FROM "user", screen_name
        WHERE
          "user".id = screen_name.owner_id
          AND
          screen_name.id IN (
            SELECT id
            FROM screen_name_read($1)
          )
        ;
      """,
      [sn]
    );

    user_id    = nil
    sn_id      = nil
    pass_match = false

    case user do
      {:error, error} -> user

      {:ok, []} ->
        {:error, [:user_error, "log_in: screen_name not found"]}

      {:ok, [%{"id"=>user_id, "pswd_hash"=>pswd_hash, "sn_id"=>sn_id}]} ->
        pass_match = Comeonin.Bcrypt.checkpw(pass, pswd_hash)

        result = Megauni.SQL.query(
          " SELECT * FROM log_in_attempt($1, $2, $3, $4); ",
          [ip, sn_id, user_id, pass_match]
        )

        case result do
          {:ok, [%{"has_pass"=>true}]} ->
            {:ok, %{"id"=>user_id}}
          {:ok, [%{"has_pass"=>false, "reason"=>reason}]} ->
            {:error, [:user_error, reason]}
        end # === case
    end # === case user
  end # === def attempt

end # === defmodule Log_In

