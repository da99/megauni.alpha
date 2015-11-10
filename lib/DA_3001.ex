
defmodule DA_3001 do

  def to_file_paths(string) when is_string(string) do
    string |> Path.wildcard
  end

  def to_file_paths(list) when is_list(list) do
    Enum.map(list, &(to_file_paths &1))
    |> List.flatten
  end

  def split(list, delim) when is_list(list) do
    Enum.map(list, &(String.split(&1, delim))
  end

  def at(list, pos) when is_list(list) do
    list |> Enum.map(&(Enum.at &1, 1))
  end

  def pluck(list, pos) when is_list(list) and is_number(pos) do
    list |> Enum.map(&(Enum.at &1, pos))
  end

  def pluck(map, key) when is_map(map) do
    map |> Enum.map(&(Enum.at &1, key))
  end

  def map(list, func) when is_list(list) do
    Enum.map list, func
  end

  def first({first, second}) when is_tuple({first, second}) do
    first
  end

end # === defmodule DA_3001
