
defmodule Megauni.Model do

  def applet_results result, prefix \\ "unknown" do
    case result do

      {:ok, meta} ->
        maps = Enum.map(meta.rows, fn(r) ->
          Enum.reduce(Enum.zip(meta.columns, r), %{}, fn({col, val}, map) ->
            Map.put(map, col, val)
          end)
        end)

        if Enum.count(maps) == 1 do
          List.first(maps)
        else
          maps
        end

      {:error, e} ->
        msg            = Exception.message(e)
        err_unique_idx = ~r/violates.+"#{prefix}_unique_idx"/
        err_exception  = ~r/^ERROR \(raise_exception\): /

        cond do
          msg =~ err_unique_idx ->
            %{"error"=> "#{prefix}: already taken"}
          msg =~ err_exception ->
            %{"error"=> Regex.replace(err_exception, msg, "")}
          true ->
            In.spect e
            %{"error"=> "#{prefix}: programmer error"}
        end # === cond

    end # === case
  end

end # === defmodule Megauni.Model
