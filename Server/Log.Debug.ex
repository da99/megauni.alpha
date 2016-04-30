
defmodule Log.Debug do

  @moduledoc """
  A customized version of:
  https://github.com/elixir-lang/plug/blob/master/lib/plug/logger.ex

      GET /index.html - Sent 200 in 572ms

  To use it, just plug it into the desired module.

      plug Log.Debug

  """

  require Logger
  alias Plug.Conn
  @behaviour Plug

  def init(opts) do
    Keyword.get(opts, :log, :debug)
  end

  def call(conn, _level) do

    meth        = conn.method
    path        = conn.request_path
    before_time = :os.timestamp()

    conn
    |> Conn.register_before_send(fn conn ->
         stat = conn.status
         level = case stat do
           _ when stat > 399 -> :error
           _ when stat > 299 -> :debug
           _ -> :info
         end

         Logger.log level, fn ->
           diff = formatted_diff(:timer.now_diff(:os.timestamp(), before_time))

           [ meth, ?\s, path, ' - ', Integer.to_string(conn.status), " in ", diff ]
         end
         conn
       end)
  end

  defp formatted_diff(diff) when diff > 1000, do: [diff |> div(1000) |> Integer.to_string, "ms"]
  defp formatted_diff(diff), do: [diff |> Integer.to_string, "µs"]
end
