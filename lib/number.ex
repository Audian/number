#
# Copyright 2017, Audian, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

defmodule Number do
  @moduledoc """
  Documentation for Number.
  """

  #-- Number patterns used for regexes --#
  @npan           ~r/\A^[2-9][0-9]{2}[2-9][0-9]{6}$\z/
  @one_npan       ~r/\A^1[2-9][0-9]{2}[2-9][0-9]{6}$\z/
  @e164           ~r/\A^\+[1-9][0-9]{10,14}$\z/
  @international  ~r/\A^(?:\+|011)[2-9][0-9]{10,14}\z/
  @tollfree       ~r/\A^(?:\+)?(?:1)?(?:800|888|877|866|855|844|833)[2-9][0-9]{6}$\z/
  @us_toll        ~r/\A^(?:\+)?(?:1)?(?:900|976)[2-9][0-9]{6}$\z/
  @npa            ~r/\A^[2-9][0-9]{2}$\z/
  @npanxx         ~r/\A^[2-9][0-9]{2}[2-9][0-9]{2}\z/
  @tf_npa         ~r/\A^(?:800|877|866|855|844|833)$\z/
  @toll_npa       ~r/\A^(?:900|977|976)$\z/

  @doc """
  Returns version
  """
  def version() do
    Number.Mixfile.project[:version]
  end

  @doc """
  Classifies a number into:
  * e164
  * npan
  * 1npan
  * us_tollfree
  * us_toll (900/976)
  * international
  """
  def classify(number) do
    cond do
      is_tolled?(number)        -> "us_toll"
      is_tollfree?(number)      -> "us_tollfree"
      is_international?(number) -> "international"
      is_npan?(number)          -> "npan"
      is_1npan?(number)         -> "1npan"
      is_e164?(number)          -> "e164"
      true                      -> "unknown"
    end
  end

  @doc """
  Converts a number to E164
  """
  def normalize_us(number) do
    case is_e164?(number) do
      true ->
        number
      false ->
        cond do
          is_npan?(number)  -> "+1#{number}"
          is_1npan?(number) -> "+#{number}"
          true              -> number
        end
    end
  end

  @doc """
  Converts a number to NPAN
  """
  def to_npan(number) do
    case classify(number) do
      "e164" ->
        Regex.replace(~r/^\+1/, number, "")
      "1npan" ->
        Regex.replace(~r/^1/, number, "")
      "npan" ->
        number
      "us_tollfree" ->
        Regex.replace(~r/^\+1/, normalize_us(number), "")
      _ ->
        {:error, :not_supported}
    end
  end

  @doc """
  Converts a number to 1npan
  """
  def to_1npan(number) do
    case classify(number) do
      "e164" ->
        Regex.replace(~r/^\+/, number, "")
      "npan" ->
        "1#{number}"
      "1npan" ->
        number
      "us_tollfree" ->
        Regex.replace(~r/^\+/, normalize_us(number), "")
    end
  end

  @doc """
  to E164, we just call the normalize_us function
  """
  def to_e164(number) do
    normalize_us(number)
  end

  #--- private ---#
  defp is_npan?(number) do
    String.match?(number, @npan)
  end

  defp is_1npan?(number) do
    String.match?(number, @one_npan)
  end

  defp is_international?(number) do
    String.match?(number, @international)
  end

  defp is_tollfree?(number) do
    String.match?(number, @tollfree)
  end

  defp is_tolled?(number) do
    String.match?(number, @us_toll)
  end

  defp is_e164?(number) do
    String.match?(number, @e164)
  end
end
