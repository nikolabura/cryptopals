IO.puts("Chal4")

strings = File.read!("data4.txt")
strings = String.split(strings)

results =
  strings
  |> Enum.map(fn hex_str ->
    ciphertext =
      String.codepoints(hex_str)
      |> Enum.chunk_every(2)
      |> Enum.map(fn list -> String.to_integer(Enum.join(list), 16) end)

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
      overall_score = Float.round(0.7 * alphas_score + 0.3 * asciis_score, 3)
      {overall_score, s, hex_str}
    end)
    |> Enum.sort()
    |> Enum.take(-1)
  end)
  |> List.flatten()
  |> Enum.sort()

IO.inspect(results, limit: :infinity)
IO.puts("The string which was encrypted by sing-char XOR should be near the bottom.")
