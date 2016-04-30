
defmodule User do

  @min 5
  @min_word 3
  @max 150

  def canonize_pass(pass_word) when is_binary(pass_word) do
    (pass_word || '')
    |> to_string
    |> String.strip
    |> String.split( ~r/[[:cntrl:]+]/, trim: true )
    |> Enum.join(" ")
  end

  def clean_pass_confirm(pass_word, confirm) when is_binary(pass_word) and is_binary(confirm) do
    confirm   = canonize_pass(confirm)
    pass_word = canonize_pass(pass_word)

    cond do
      String.length(pass_word) < @min ->
        {:error, [:user_error, "pass_word: min #{@min}"]}

      String.length(pass_word) > @max ->
        {:error, [:user_error, "pass_word: max #{@max}"]}

      (Enum.count(String.split(pass_word, ~r/\s/, trim: true)) < @min_word) ->
        {:error, [:user_error, "pass_word: min_words #{@min_word}"]}

      (confirm !== pass_word) ->
        {:error, [:user_error, "confirm_pass_word: no match"]}

      true ->
        pass_word
    end # === cond
  end # === def clean_password pswd

  def create(%{"screen_name"=>sn, "pass"=>raw_pass, "confirm_pass"=>confirm_pass})
  when is_binary(sn) and is_binary(raw_pass) and is_binary(confirm_pass) do
    data = %{"screen_name"=>sn, "pass"=>raw_pass, "confirm_pass"=>confirm_pass}

    clean_pass = clean_pass_confirm(data["pass"], data["confirm_pass"])
    case clean_pass do
      {:error, [:user_error,_msg]} ->
        clean_pass

      _ when is_binary(clean_pass) ->
        Megauni.SQL.query(
          """
            SELECT id, screen_name
            FROM user_insert( $1, $2 );
          """,
          [
            data["screen_name"],
            Comeonin.Bcrypt.hashpwsalt( clean_pass )
          ]
        )
        |> Megauni.SQL.one_row("screen_name")
    end # === case clean_pass


  end # === def update

end # === defmodule User


