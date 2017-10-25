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

defmodule Number.Formatter do
  @moduledoc """
  Module to pretty format numbers. Currently works for US numbers only.
  """

  @us_nanp  ~r/\A^(?<areacode>[2-9][0-9]{2})(?<exchange>[2-9][0-9]{2})(?<subscriber>[0-9]{4})$\z/

  def pretty_format(number) do
    case is_formattable?(number) do
      true -> 
        npan_n = Number.to_npan(number)

        # split the number into its parts
        %{"areacode" => areacode, "exchange" => exchange, "subscriber" => subscriber} = Regex.named_captures(@us_nanp, npan_n)
        "+1 (#{areacode}) #{exchange}-#{subscriber}"
      false -> number
    end
  end

  #-- Private --#
  def is_formattable?(number) do
    case Number.classify(number) do
      n when n in ["npan", "1npan"] ->
        true
      "e164" ->
        Number.is_use164?(number)
      _ -> false
    end
  end
end
