
defmodule In do

  def dev! do
    if dev? do
      true
    else
      raise "Only available during development."
    end
  end

  def dev? do
    dev
  end

  def dev do
    !!System.get_env("IS_DEV")
  end

  def spect(var) do
    if System.get_env("IS_DEV") do
      IO.inspect(var)
    else
      nil
    end
  end # === def spect(var)

  def repeat var do
    spect var
    var
  end

end # === defmodule In
