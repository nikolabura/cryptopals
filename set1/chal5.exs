IO.puts("Chal5")

plaintext = "Burning 'em, if you ain't quick and nimble
I go crazy when I hear a cymbal"
plaintext = String.to_charlist(plaintext)
key = ~c(ICE)
keylength = length(key)
IO.inspect(plaintext)
IO.inspect(key)

out =
  plaintext
  |> Enum.with_index()
  |> Enum.map(fn {c, i} ->
    keychar = Enum.at(key, rem(i, keylength))

    Bitwise.bxor(c, keychar)
    |> Integer.to_string(16)
    |> String.pad_leading(2, "0")
  end)
  |> Enum.join()
  |> String.downcase()

IO.inspect(out)
