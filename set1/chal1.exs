IO.puts("Chal1")

defmodule Chal1 do
  def base64_string, do: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  def charToVal(nibble) do
    case nibble do
      ?0 -> 0
      ?1 -> 1
      ?2 -> 2
      ?3 -> 3
      ?4 -> 4
      ?5 -> 5
      ?6 -> 6
      ?7 -> 7
      ?8 -> 8
      ?9 -> 9
      ?a -> 10
      ?b -> 11
      ?c -> 12
      ?d -> 13
      ?e -> 14
      ?f -> 15
    end
  end
end
#np = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
inp = "49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"
IO.inspect(inp)

use Bitwise
twobits = inp
  |> String.downcase()
  |> String.to_charlist()
  |> Enum.map(fn byte ->
    val = Chal1.charToVal(byte)
    high = val >>> 2
    low = val &&& 0b0011
    [high, low]
  end)
  |> List.flatten()
#IO.inspect(twobits, base: :binary)

outb64 = twobits
  |> Enum.chunk_every(3)
  |> Enum.map(fn sextet ->
    sextet = for x <- sextet, do: <<x::2>>, into: <<>>
    value = case sextet do
      <<value::size(6)>> -> value
      <<value::size(4)>> -> value <<< 2
      <<value::size(2)>> -> value <<< 4
    end
    String.at(Chal1.base64_string(), value)
  end)
  |> Enum.join()
IO.inspect(outb64)
