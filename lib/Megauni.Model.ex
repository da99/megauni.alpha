
defmodule Megauni.Model do

  def applet_results result, prefix \\ "unknown" do
    case result do

      {:ok, meta} ->
        Enum.map(meta.rows, fn(r) ->
          Enum.reduce(Enum.zip(meta.columns, r), %{}, fn({col, val}, map) ->
            Map.put(map, col, val)
          end)
        end)

      {:error, e} ->
        msg            = Exception.message(e)
        err_unique_idx = ~r/violates.+"#{prefix}_unique_idx"/
        err_exception  = ~r/^ERROR \(raise_exception\): /

        cond do
          msg =~ err_unique_idx ->
            [%{"error"=> "#{prefix}: already_taken"}]
          msg =~ err_exception ->
            [%{"error"=> Regex.replace(err_exception, msg, "")}]
        end # === cond

    end # === case
  end

end # === defmodule Megauni.Model
