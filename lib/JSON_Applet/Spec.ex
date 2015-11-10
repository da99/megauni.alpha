

defmodule JSON_Applet.Spec do

  import JSON_Applet.Applet, only: :functions
  @reset   IO.ANSI.reset
  @bright  IO.ANSI.bright
  @green   IO.ANSI.green
  @yellow  "#{@bright}#{IO.ANSI.yellow}"
  @red     "#{@bright}#{IO.ANSI.red}"

  def spec_funcs do
    aliases = %{
      "==="        => :exactly_like,
      "~="         => :similar_to
    }
    Map.merge spec_func_map(JSON_Applet.Spec), aliases
  end

  def spec_func_map mod do
    Enum.reduce mod.__info__(:functions), %{}, fn({name, arity}, map) ->
      if arity == 3 do
        map = Map.put map, Atom.to_string(name), name
      end
      map
    end
  end


  def similar_to!(actual, expected) when is_map(actual) and is_map(expected) do
    key = Enum.find Map.keys(expected), fn(k) ->
      cond do
        (is_integer(actual[k]) && expected[k] == "INT") ->
          false
        true ->
          !(actual[k] == expected[k])
      end
    end
    if key do
      IO.puts "#{@bright}Key mismatch: #{key} : #{inspect actual[key]} != #{@red}#{inspect expected[key]}#{@reset}"
      IO.puts "#{@bright}#{inspect actual}"
      IO.puts "#{@reset}#{@red}#{@bright}#{inspect expected}"
      IO.puts @reset
      raise "spec failed"
    else
      true
    end
  end

  def similar_to!(actual, expected) when is_list(actual) and is_list(expected) do
    if Enum.count(actual) != Enum.count(expected) do
      similar_to_fail actual, expected
    end

    Enum.find Enum.with_index(expected), fn({val, i}) ->
      ! similar_to!( Enum.at(actual,i), Enum.at(expected, i))
    end
  end

  def similar_to!(actual, expected) when is_binary(actual) and is_binary(expected) do
    if actual != expected do
      similar_to_fail actual, expected
    end
    true
  end

  def similar_to!(actual, expected) when is_binary(actual) and is_map(expected) do
    if !(actual =~ expected) do
      similar_to_fail actual, expected
    end
    true
  end

  def similar_to_fail actual, expected do
    IO.puts "\n#{@bright}#{inspect actual} needs to be similar to #{@reset}#{@red}#{@bright}#{inspect expected}"
    IO.puts @reset
    raise "spec failed"
  end

  def similar_to! actual, expected do
    if actual == expected do
      true
    else
      IO.puts "\n#{@bright}#{inspect actual} needs to be similar to #{@reset}#{@red}#{@bright}#{inspect expected}"
      IO.puts @reset
      Process.exit(self, "spec failed")
    end
  end

  def failed actual, expected, env do
    IO.print "\r"
    num = "#{JSON_Spec.format_num(env.it_count)})"
    IO.puts "#{@bright}#{@red}#{num}#{@reset}#{@bright} #{env.it}"
    IO.puts "#{@bright}#{inspect expected} !== #{@reset}#{@red}#{@bright}#{inspect env.actual}"
    IO.puts @reset
    Process.exit(self, "spec failed")
  end # === def failed

  def is_error? e do
    is_map(e) &&
    (
      Map.has_key?(e, "error") ||
      Map.has_key?(e, "user_error") ||
      Map.has_key?(e, "user error") ||
      Map.has_key?(e, "programmer_error") ||
      Map.has_key?(e, "programmer error")
    )
  end

  def format_num(num) do
    space = String.duplicate " ", 2 - String.length(to_string(num))
    "#{space}#{num}"
  end

  def is_list_of_maps? list do
    if !is_list(list) do
      false
    else
      !Enum.find list, fn(v) ->
        !is_map(v)
      end
    end
  end

  def all_funcs? map, list do
    Enum.all? Map.keys(map), fn(k) ->
      Enum.find_index(list, fn (x) -> x == k end)
    end
  end

  def all_funcs! map, list do
    Enum.each Map.keys(map), fn(k) ->
      if !Enum.find_index(list, fn (x) -> x == k end) do
        raise "func not found: #{inspect k}"
      end
    end
  end # === def all_funcs!

  def run_files files, env \\ nil do
    Enum.each files, fn(file) ->
      run_file(file, env)
    end
  end # == def run_files

  def run_file(path, raw_env \\ %{}) do
    # === Defaults for env
    env = to_map([
      JSON_Applet.Funcs,
      JSON_Applet.Spec_Funcs,
      raw_env,
      %{ :spec_count => 0, :it_count => 0 }
    ])

    {_stack, _prog, env} = run(
      [], (path |> File.read! |> Poison.decode!), env
    )

    IO.puts "\nfile: #{@bright}#{path}#{@reset}"
    if env.spec_count > 0 do
      IO.puts "#{@bright}#{@green}All tests pass.#{@reset}"
    else
      IO.puts "#{@bright}#{@red}No tests found.#{@reset}"
    end
  end # === run_file

end # === defmodule JSON_Spec

