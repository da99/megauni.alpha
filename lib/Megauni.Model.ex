
defmodule Megauni.Model do

  @user_err_regexp  ~r/\Auser_error: /

  def max_length raw do
    case raw do
      { :error, %{postgres: %{code: :string_data_right_truncation, message: msg}} } ->
        case Regex.run( ~r/value too long for type character varying\((\d+)\)/, msg ) do
          [match, raw_num] ->
            String.to_integer(raw_num)
          nil ->
            nil
        end
      _ ->
        nil
    end
  end # === def max_length

  def is_too_long? raw do
    is_number(max_length(raw))
  end # === def is_too_long?

  defp inspect_and_raise_db_err result, err_code, msg do
    In.spect result
    raise "\n\ndatabase error: #{inspect err_code} #{msg}"
  end

  def rows raws do
    case raws do
      {:ok, %{num_rows: num_rows, columns: cols, rows: rows }} ->
        Enum.map rows, fn(r) ->
          Enum.reduce(Enum.zip(cols, r), %{}, fn({col, val}, map) ->
            Map.put(map, col, val)
          end)
        end

      {:error, e} ->
        In.spect e
        raise "\n\n database error"
    end # === case raws
  end # === def rows

  @doc """
  This function standardizes errors. There are different
  ways to validate data on Postgresql (constraints, triggers, pgSQL funcs, etc).
  The idea is to take advantage of the "datastore" (Postgresql in this case).
    - "error" are for unforeseen errors generated by Postgresql.
    - "user_error" are foreseen that can be dealt by the user.
  """
  def one_row result, prefix \\ "unknown" do
    case result do

      {:ok, %{num_rows: 1, columns: cols, rows: [row]}} ->
        Enum.reduce(Enum.zip(cols, row), %{}, fn({col, val}, map) ->
          Map.put(map, col, val)
        end)

      { :error, %{postgres: %{code: :unique_violation, message: msg}} } ->
        if msg =~ ~r/violates.+"#{prefix}_unique_idx"/ do
          %{"user_error"=> "#{prefix}: already_taken"}
        else
          inspect_and_raise_db_err result, :unique_violation, msg
        end

      { :error, %{postgres: %{code: :raise_exception, message: msg}} } ->
        cond do
          msg =~ @user_err_regexp ->
            %{"user_error" => String.replace(msg, ~r/\Auser_error: /, "", global: false) }

          true ->
            inspect_and_raise_db_err(result, :raise_exception, msg)
        end

      { :error, %{postgres: %{code: err_code, message: msg}} } ->
        inspect_and_raise_db_err(result, err_code, msg)

      {:error, e} ->
        msg            = Exception.message(e)
        err_unique_idx = ~r/violates.+"#{prefix}_unique_idx"/
        err_exception  = ~r/^ERROR \(raise_exception\): /

        cond do
          msg =~ err_unique_idx ->
            %{"user_error"=> "#{prefix}: already_taken"}
          msg =~ err_exception ->
            %{"error"=> Regex.replace(err_exception, msg, "")}
        end # === cond
    end # === case
  end # === def one_row

end # === defmodule Megauni.Model




