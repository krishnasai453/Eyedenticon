defmodule Eyedenticon do
  def generate(name) do
    name
    |> hash_input()
    |> pick_color()
    |> build_grid()
    |> filter_odd_grid_values()
    |> build_pixel_map()
    |> draw_identicon_image()
    |> save_identicon_image(name)
  end

  def hash_input(name_input) do
    hex =
      :crypto.hash(:md5, name_input)
      |> :binary.bin_to_list()

    %Eyedenticon.Image{hex: hex}
  end

  def pick_color(%Eyedenticon.Image{hex: [red, green, blue | _remaining_list]} = image) do
    %Eyedenticon.Image{image | color: {red, green, blue}}
  end

  def build_grid(%Eyedenticon.Image{hex: hex_list} = image) do
    grid =
      hex_list
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(fn row -> mirror_row(row) end)
      |> List.flatten()
      |> Enum.with_index()

    %Eyedenticon.Image{image | grid: grid}
  end

  def filter_odd_grid_values(%Eyedenticon.Image{grid: grid} = image) do
    new_grid = grid |> Enum.filter(fn {val, _index} -> rem(val, 2) == 0 end)
    %Eyedenticon.Image{image | grid: new_grid}
  end

  def build_pixel_map(%Eyedenticon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_val, index} ->
        horizonral = rem(index, 5) * 50
        vertical = div(index, 5) * 50
        top_left = {horizonral, vertical}
        bottom_right = {horizonral + 50, vertical + 50}
        {top_left, bottom_right}
      end)

    %Eyedenticon.Image{image | pixel_map: pixel_map}
  end

  def draw_identicon_image(%Eyedenticon.Image{color: chosen_color, pixel_map: pixel_map} = image) do
    image_area = :egd.create(250, 250)
    fill_area = :egd.color(chosen_color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image_area, start, stop, fill_area)
    end)

    :egd.render(image_area)
  end

  def save_identicon_image(image, filename) do
    File.write("#{filename}.png", image)
  end

  defp mirror_row([first, second | tail]) do
    [first, second | tail] ++ [second, first]
  end
end
