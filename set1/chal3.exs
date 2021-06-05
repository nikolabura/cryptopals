IO.puts("Chal3")

ciphertext = "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
IO.inspect(ciphertext)

ciphertext =
  String.codepoints(ciphertext)
  |> Enum.chunk_every(2)
  |> Enum.map(fn list -> String.to_integer(Enum.join(list), 16) end)

IO.inspect(ciphertext)

xored =
  Enum.map(0..255, fn val ->
    ciphertext
    |> Enum.map(fn char ->
      Bitwise.bxor(char, val)
    end)
    |> List.to_string()
  end)
  |> Enum.filter(fn s -> String.printable?(s) end)
  |> Enum.map(fn s ->
    num_alphas =
      String.codepoints(s)
      |> Enum.map(fn p ->
        String.match?(p, ~r/[[:alpha:]]/)
      end)
      |> Enum.count(fn x -> x end)

    num_ascii =
      String.to_charlist(s)
      |> Enum.filter(fn c -> c <= 127 end)
      |> Enum.count()

    tot_chars = String.length(s)
    alphas_score = num_alphas / tot_chars
    asciis_score = num_ascii / tot_chars
    overall_score = 0.7 * alphas_score + 0.3 * asciis_score
    {overall_score, alphas_score, asciis_score, s}
  end)
  |> Enum.sort()

IO.inspect(xored, limit: :infinity)
IO.puts("The bottommost string above should be the answer.")
