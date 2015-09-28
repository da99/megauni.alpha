
defmodule User do

  @min = 10
  @max = 300

  def clean_password confirm, pass_word do
    confirm   = (confirm   || '') |> to_string |> String.strip
    pass_word = (pass_word || '') |> to_string |> String.strip

    cond do
      (String.length(pass_word) < min) ->
        %{"error" => "pass_word: min #{@min}"}

      (String.length(pass_word) > max) ->
        %{"error" => "pass_word: max #{@max}"}

      (String.split(pass_word, ~r/\s/, trim: true) < 3) ->
        %{"error" => "pass_word: min 3 words"}

      (confirm !== pass_word) ->
        %{"error" => "confirm_pass_word: no match"}

      true ->
        pass_word
    end # === cond
  end # === def clean_password pswd

  def create raw_data do
    data = raw_data

    clean_pass = clean_password(data["confirm_pass"], data["pass"])
    case clean_pass do

      %{"error"=>_msg) ->
          clean_pass

      _ ->
        case sn do
          %{"error" => _msg} ->
            sn
          _ ->
            pswd_hash = Comeonin.Bcrypt.hashpwsalt( clean_pass )
            result = Ecto.Adapters.SQL.query(
              Megauni.Repos.Main,
              """
                INSERT INTO user ( screen_name , pswd_hash )
                VALUES           ( $1 , $2        )
                RETURNING        id ;
              """,
              [raw_data["screen_name"], pswd_hash]
            )
            Megauni.Model.applet_results(result, "user")
        end # === case sn
    end # === case clean_pass


  end # === def update

end # === defmodule User


