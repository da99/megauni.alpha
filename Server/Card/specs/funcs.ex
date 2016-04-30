
defmodule Card.Spec_Funcs do

  def card stack, [[] | prog], env do
    num = JSON_Applet.get(:card_counter, env)
    card(stack, [[num] | prog], env)
  end

  def card(stack, [[str] | prog], env) when is_binary(str) do
    card stack, [[String.to_integer(str)] | prog], env
  end

  def card(stack, [[num] | prog], env) when is_number(num) do
    card = JSON_Applet.get(:"card_#{num}", env)
    {stack ++ [card], prog, env}
  end

  def create_card(stack, prog, env) do
    data = if (prog |> List.first |> is_map) do
      {data, prog, env} = JSON_Applet.take(prog, 1, env)
      data
    else
      user = JSON_Applet.get(:user, env)
      sn   = JSON_Applet.get(:sn, env)
      %{
        "owner_id"          => user["id"],
        "owner_screen_name" => sn["screen_name"],
        "privacy"           => "WORLD READABLE",
        "code"              => [%{"cmd": "time"}]
      }
    end

    result = Card.create data
    case result do
      {:ok, map = %{"id"=> _card}} ->
        env = JSON_Applet.put(env, :card, map)
    end

    {stack ++ [result |> JSON_Applet.to_json_to_elixir], prog, env}
  end

end # === defmodule Card.Spec_Funcs
