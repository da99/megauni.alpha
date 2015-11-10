
defmodule DA_3001 do

  @reset   IO.ANSI.reset
  @bright  IO.ANSI.bright
  @green   IO.ANSI.green
  @yellow  "#{@bright}#{IO.ANSI.yellow}"
  @red     "#{@bright}#{IO.ANSI.red}"

  def color(list) when is_list(list) do
    Enum.map list, fn(string_or_atom) ->
      case string_or_atom do
        :reset ->  @reset
        :bright -> @bright
        :green ->  @green
        :yellow -> "#{@bright}#{@yellow}"
        :red   -> "#{@bright}#{@red}"
        str when is_binary(str) -> str
        num when is_number(num) -> to_string(num)
      end
    end
    |> Enum.join
  end

  def to_file_paths(string) when is_binary(string) do
    string |> Path.wildcard
  end

  def to_file_paths(list) when is_list(list) do
    Enum.map(list, &(to_file_paths &1))
    |> List.flatten
  end

  def split(list, delim) when is_list(list) do
    Enum.map list, &(String.split &1, delim)
  end

  def at(list, pos) when is_list(list) do
    list |> Enum.map(&(Enum.at &1, pos))
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
