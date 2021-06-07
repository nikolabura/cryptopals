IO.puts("Chal6")

use Bitwise

defmodule Chal6 do
  def hammingDistance(str1, str2) do
    Enum.zip(str1, str2)
    |> Enum.reduce(0, fn tup, acc ->
      differing_bits =
        Bitwise.bxor(elem(tup, 0), elem(tup, 1))
        |> Integer.to_string(2)
        |> String.codepoints()
        |> Enum.filter(fn x -> x == "1" end)
        |> Enum.count()

      acc + differing_bits
    end)
  end
end

base64 = File.read!("data6.txt")

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

# steps 1, 2 and 3 (keysize trials)
do_trials = true

keysize =
  if do_trials do
    keysize_trials =
      Enum.map(2..min(40, div(length(ciphertext), 2)), fn keysize ->
        blocks =
          ciphertext
          |> Enum.chunk_every(keysize)
          |> Enum.filter(fn c -> length(c) == keysize end)
          |> Enum.take(70)

        score =
          for x <- blocks, y <- blocks, x != y do
            Chal6.hammingDistance(x, y) / keysize
          end

        IO.write(keysize)
        IO.write(" ")
        score = Enum.sum(score) / length(score)
        %{score: Float.round(score, 4), keysize: keysize}
      end)
      |> Enum.sort_by(fn p -> p.score end, :desc)

    IO.puts("Done trialing KEYSIZE.")

    keysize_trials
    |> Enum.take(-8)
    |> IO.inspect()

    # step 4 (choose keysize)
    keysize_trials |> Enum.at(-1) |> Map.fetch!(:keysize)
  else
    # hardcoded result from previously run trials
    29
  end

IO.write("Using KEYSIZE: ")
IO.puts(keysize)

# step 5 (break into blocks)
blocks =
  ciphertext
  |> Enum.chunk_every(keysize)
  # drop the last
  |> Enum.filter(fn c -> length(c) == keysize end)

# step 6 (transpose)
blocks =
  Enum.reduce(0..(keysize - 1), [], fn index, acc ->
    acc ++ [Enum.map(blocks, fn b -> Enum.at(b, index) end)]
  end)

# step 7 (solve each block)
blocks
|> Enum.map(fn block ->
  # try single-character 0-255 on the block
  Enum.map(0..255, fn charguess ->
    xored = Enum.map(block, fn x -> Bitwise.bxor(x, charguess) end)
    %{guess: charguess, result: xored}
  end)
  # filter out keys which result in many non-ascii chars or in any unprintable string
  |> Enum.filter(fn g ->
    ascii_good = Enum.count(g.result, fn c -> c <= 127 end) / length(g.result) > 0.5
    print_good = String.printable?(List.to_string(g.result))
    ascii_good and print_good
  end)
  # do the histogram
  |> Enum.map(fn g ->
    freq =
      Enum.frequencies(g.result)
      |> Map.to_list()
      |> Enum.sort_by(&elem(&1, 1), :desc)

    Map.put(g, :freq, freq)
  end)
  # filter out keys where E and T frequency is not near the top
  |> Enum.filter(fn g ->
    ordered_letter_freqs =
      g.freq
      |> Enum.map(&elem(&1, 0))

    e_in_top =
      Enum.take(ordered_letter_freqs, 5)
      |> Enum.any?(fn c -> c in ~c(eE) end)

    t_in_top =
      Enum.take(ordered_letter_freqs, 10)
      |> Enum.any?(fn c -> c in ~c(tT) end)

    e_in_top or t_in_top
    true
  end)
  # do the "number of alphabetic chars vs number of total chars" score
  |> Enum.map(fn g ->
    num_alphas =
      String.codepoints(List.to_string(g.result))
      |> Enum.map(fn p ->
        String.match?(p, ~r/[[:alpha:]]/)
      end)
      |> Enum.count(fn x -> x end)

    tot_chars = length(g.result)
    alphas_score = num_alphas / tot_chars
    Map.put(g, :alphas_score, alphas_score)
  end)
  |> Enum.sort_by(&Map.get(&1, :alphas_score))
  |> Enum.map(&Map.put(&1, :result_string, List.to_string(&1.result)))
  |> Enum.take(-1)
  |> Enum.map(&Map.get(&1, :guess))
end)
|> Enum.join()
|> (fn x ->
      IO.write("Guessed key: ")
      x
    end).()
|> IO.inspect()
