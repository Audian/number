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

  # -- Number patterns used for regexes --#
  @npan ~r/\A^[2-9][0-9]{2}[2-9][0-9]{6}$\z/
  @one_npan ~r/\A^1[2-9][0-9]{2}[2-9][0-9]{6}$\z/
  @us_e164 ~r/\A^\+1[2-9][0-9]{2}[2-9][0-9]{6}$\z/
  @e164 ~r/\A^\+[1-9][0-9]{10,14}$\z/
  @international ~r/\A^(?:\+|011)[2-9][0-9]{5,14}\z/
  @tollfree ~r/\A^(?:\+)?(?:1)?(?:800|888|877|866|855|844|833)[2-9][0-9]{6}$\z/
  @us_toll ~r/\A^(?:\+)?(?:1)?(?:900|976)[2-9][0-9]{6}$\z/
  @us_intl ~r/\A^011[2-9][0-9]{5,14}$\z/

  @doc """
  Returns version
  """
  def version() do
    Number.Mixfile.project()[:version]
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
  @spec classify(number :: String.t()) :: String.t()
  def classify(number) do
    cond do
      is_tolled?(number) ->
        "us_toll"

      is_tollfree?(number) ->
        "us_tollfree"

      is_international?(number) ->
        "international"

      is_npan?(number) ->
        "npan"

      is_1npan?(number) ->
        "1npan"

      is_e164?(number) ->
        case is_use164?(number) do
          true ->
            "us_e164"

          false ->
            case is_international_e164?(number) do
              true -> "international"
              false -> "unknown"
            end
        end

      true ->
        "unknown"
    end
  end

  @doc """
  Normalize a number
  """
  @spec normalize(number :: String.t()) :: String.t()
  def normalize(number) do
    case classify(number) do
      n when n in ["e164", "us_e164", "npan", "1npan", "us_tollfree", "us_toll"] ->
        case is_e164?(number) do
          true ->
            number

          false ->
            cond do
              is_npan?(number) -> "+1#{number}"
              is_1npan?(number) -> "+#{number}"
              true -> number
            end
        end

      "international" ->
        case is_e164?(number) do
          true ->
            number

          false ->
            case is_usintl?(number) do
              true ->
                Regex.replace(~r/\A^011/, number, "+")

              false ->
                number
            end
        end

      _ ->
        "Unknown"
    end
  end

  @doc """
  Converts a number to NPAN
  """
  @spec to_npan(number :: String) :: String.t()
  def to_npan(number) do
    case classify(number) do
      "e164" ->
        Regex.replace(~r/^\+1/, number, "")

      "1npan" ->
        Regex.replace(~r/^1/, number, "")

      "npan" ->
        number

      "us_tollfree" ->
        Regex.replace(~r/^\+1/, normalize(number), "")

      _ ->
        "invalid"
    end
  end

  @doc """
  Converts a number to 1npan
  """
  @spec to_1npan(number :: String.t()) :: String.t()
  def to_1npan(number) do
    case classify(number) do
      "e164" ->
        Regex.replace(~r/^\+/, number, "")

      "npan" ->
        "1#{number}"

      "1npan" ->
        number

      "us_tollfree" ->
        Regex.replace(~r/^\+/, normalize(number), "")

      _ ->
        "invalid"
    end
  end

  @doc """
  Converts an international number to us_intl format
  """
  @spec to_usintl(number :: String.t()) :: String.t()
  def to_usintl(number) do
    case classify(number) do
      "international" ->
        case is_e164?(number) do
          true ->
            Regex.replace(~r/\+/, number, "011")

          false ->
            number
        end

      _ ->
        number
    end
  end

  @doc """
  Checks to see if the provided number is 10digit E164
  """
  @spec is_use164?(number :: String.t()) :: Boolean.t()
  def is_use164?(number) do
    case is_e164?(number) do
      true ->
        String.match?(number, @us_e164)

      false ->
        false
    end
  end

  @doc """
  Checks to see if the supplied number is E164
  """
  @spec is_international_e164?(did :: String.t()) :: Boolean.t()
  def is_international_e164?(did) do
    is_e164?(did) && is_international?(did)
  end

  @doc """
  to E164, we just call the normalize_us function
  """
  @spec to_e164(number :: String.t()) :: String.t()
  def to_e164(number) do
    normalize(number)
  end

  # --- private ---#
  @spec is_npan?(number :: String.t()) :: String.t()
  defp is_npan?(number) do
    String.match?(number, @npan)
  end

  @spec is_1npan?(number :: String.t()) :: String.t()
  defp is_1npan?(number) do
    String.match?(number, @one_npan)
  end

  @spec is_international?(number :: String.t()) :: String.t()
  defp is_international?(number) do
    String.match?(number, @international)
  end

  @spec is_tollfree?(number :: String.t()) :: String.t()
  defp is_tollfree?(number) do
    String.match?(number, @tollfree)
  end

  @spec is_tolled?(number :: String.t()) :: String.t()
  defp is_tolled?(number) do
    String.match?(number, @us_toll)
  end

  @spec is_e164?(number :: String.t()) :: String.t()
  defp is_e164?(number) do
    String.match?(number, @e164)
  end

  @spec is_usintl?(number :: String.t()) :: String.t()
  defp is_usintl?(number) do
    String.match?(number, @us_intl)
  end
end
