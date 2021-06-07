IO.puts("Chal8")

strings = File.read!("data8.txt")
strings = String.split(strings)

out =
  strings
  |> Enum.map(fn s ->
    String.codepoints(s)
    |> Enum.chunk_every(2)
    |> Enum.map(fn list -> String.to_integer(Enum.join(list), 16) end)
    |> Enum.chunk_every(16)
  end)
  |> Enum.map(fn blocks ->
    equivalent_blocks = for x <- blocks, y <- blocks, x == y, do: 1
    length(equivalent_blocks) - 10
  end)

IO.inspect(out, limit: :infinity)

IO.write("Line #")
IO.write(Enum.find_index(out, fn v -> v != 0 end) + 1)
IO.puts(" is probably ECB-encrypted.")
