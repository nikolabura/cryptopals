IO.puts("Chal2")

input1 = "1c0111001f010100061a024b53535009181c"
input2 = "686974207468652062756c6c277320657965"
IO.inspect(input1)
IO.inspect(input2)

out =
  Enum.zip(String.codepoints(input1), String.codepoints(input2))
  |> Enum.map(fn {x, y} ->
    x = String.to_integer(x, 16)
    y = String.to_integer(y, 16)
    Integer.to_string(Bitwise.bxor(x, y), 16)
  end)
  |> Enum.join()

IO.inspect(out)
