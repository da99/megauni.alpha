
defmodule In do
  def spect(var) do
    if System.get_env("IS_DEV") do
      IO.inspect(var)
    else
      nil
    end
  end # === def spect(var)
end # === defmodule In
