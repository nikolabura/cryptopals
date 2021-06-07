IO.puts("Chal7")

use Bitwise

base64 = File.read!("data7.txt")

base64 =
  base64
  |> String.codepoints()
  |> Enum.filter(fn c -> c != "\n" end)
  |> Enum.join()

base64_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

ciphertext =
  base64
  |> String.codepoints()
  |> Enum.map(fn c ->
    base64_alphabet
    |> String.codepoints()
    |> Enum.find_index(fn x -> x == c end)
  end)
  |> Enum.filter(fn c -> c != nil end)
  |> Enum.reduce([], fn c, acc ->
    newbits =
      c
      |> Integer.to_string(2)
      |> String.pad_leading(6, "0")
      |> String.codepoints()
      |> Enum.map(fn p -> if p == "0", do: 0, else: 1 end)

    acc ++ newbits
  end)
  |> Enum.chunk_every(8)
  |> Enum.filter(fn l -> length(l) == 8 end)
  |> Enum.map(fn byte ->
    byte
    |> Enum.join()
    |> String.to_integer(2)
  end)
  |> :erlang.list_to_binary()

IO.inspect(ciphertext)

plaintext = :crypto.crypto_one_time(:aes_128_ecb, ~c(YELLOW SUBMARINE), ciphertext, false)

plaintext
|> String.codepoints()
|> Enum.filter(fn p -> String.printable?(p) end)
|> Enum.join("")
|> IO.inspect(limit: :infinity)
