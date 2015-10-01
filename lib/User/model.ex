
defmodule User do

  @min 5
  @min_word 3
  @max 150

  def canonize_pass pass_word do
    (pass_word || '')
    |> to_string
    |> String.strip
    |> String.split( ~r/[[:cntrl:]+]/, trim: true )
    |> Enum.join(" ")
  end

  def clean_pass_confirm pass_word, confirm do
    confirm   = canonize_pass(confirm)
    pass_word = canonize_pass(pass_word)

    cond do
      String.length(pass_word) < @min ->
        %{"error" => "pass_word: min #{@min}"}

      String.length(pass_word) > @max ->
        %{"error" => "pass_word: max #{@max}"}

      (Enum.count(String.split(pass_word, ~r/\s/, trim: true)) < @min_word) ->
        %{"error" => "pass_word: min_words #{@min_word}"}

      (confirm !== pass_word) ->
        %{"error" => "confirm_pass_word: no match"}

      true ->
        pass_word
    end # === cond
  end # === def clean_password pswd

  def create raw_data do
    data = raw_data

    clean_pass = clean_pass_confirm(data["pass"], data["confirm_pass"])
    case clean_pass do

      %{"error"=>_msg} ->
          clean_pass

      _ ->
        pswd_hash = Comeonin.Bcrypt.hashpwsalt( clean_pass )
        Ecto.Adapters.SQL.query(
          Megauni.Repos.Main,
          """
            SELECT id, screen_name
            FROM user_insert( $1 , $2 );
          """,
          [raw_data["screen_name"], pswd_hash]
        )
        |> Megauni.Model.applet_results "user"
    end # === case clean_pass


  end # === def update

end # === defmodule User


