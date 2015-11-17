
defmodule DA_3001 do

  @reset   IO.ANSI.reset
  @bright  IO.ANSI.bright
  @green   IO.ANSI.green
  @yellow  "#{@bright}#{IO.ANSI.yellow}"
  @red     "#{@bright}#{IO.ANSI.red}"

  def get! name do
    val = System.get_env(name)
    case val do
      nil -> raise "System env variable not set: #{inspect name}"
      _ -> val
    end
  end

  @doc """
    Applies the :func_name to the first module in :mod_list
    that has a function named == :func_name.
    Raises an error if function is not found.
  """
  def apply_on_first!(mod_list, func_name, args) when is_list(mod_list) and is_atom(func_name) and is_list(args) do
    target = Enum.find(mod_list, fn(x) ->
      !is_nil( x.__info__(:functions)[func_name] )
    end)

    if is_nil(target) do
      raise "Function not found: #{inspect func_name}, in #{inspect mod_list}"
    end

    apply( target, func_name, args )
  end

  def puts(list) when is_list(list) do
    list |> color |> IO.puts
  end

  def write_pid! path do
    File.touch! path
    pid = to_string :os.getpid
    content = Enum.join([File.read!(path), pid], "\n")
              |> String.strip
    File.write! path, content

    String.to_integer pid
  end

  def color(list) when is_list(list) do
    Enum.map(list, fn(string_or_atom) ->
      case string_or_atom do
        :reset ->  @reset
        :bright -> @bright
        :green ->  @green
        :yellow -> "#{@bright}#{@yellow}"
        :red   -> "#{@bright}#{@red}"
        str when is_binary(str) -> str
        num when is_number(num) -> to_string(num)
      end
    end)
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

  def first({first, second, third}) when is_tuple({first, second, third}) do
    first
  end

  def ok_second({:ok, second}) do
    second
  end

  def ok_second_if_tuple {:ok, val} do
    val
  end

  def ok_second_if_tuple val do
    val
  end

end # === defmodule DA_3001
