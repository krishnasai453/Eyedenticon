defmodule Eyedenticon do
  def main(name) do
    name
    |> hash_input()
  end

  def hash_input(name_input) do
    :crypto.hash(:md5, name_input)
    |> :binary.bin_to_list()
  end

end
