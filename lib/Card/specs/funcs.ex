
defmodule Card.Spec_Funcs do

  def create_card(stack, prog, env) do
    if (prog |> List.first |> is_map) do
      {data, prog, env} = JSON_Applet.take(prog, 1, env)
    else
      data = %{
        "owner_id"          => env["user"]["id"],
        "owner_screen_name" => env["sn"]["screen_name"],
        "privacy"           => "WORLD READABLE",
        "code"              => [%{"cmd": "time"}]
      }
    end

    result = Card.create data
    case result do
      %{"id"=> _card} ->
        env = JSON_Applet.put(env, "card", result)
      _ ->
        result
    end

    {stack ++ [result], prog, env}
  end

end # === defmodule Card.Spec_Funcs
