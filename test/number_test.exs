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
defmodule NumberTest do
  use ExUnit.Case
  doctest Number

  test "number classifications" do
    assert "e164"   === Number.classify("+12065551212")
    assert "1npan"  === Number.classify("12065551212")
    assert "npan"   === Number.classify("2063130566")
    assert "international" === Number.classify("01196855554444")
    assert "international" === Number.classify("+968555544444")
  end

  test "number conversions" do
    assert "+12065551212" === Number.to_e164("2065551212")
    assert "12065551212"  === Number.to_1npan("2065551212")
    assert "2065551212"   === Number.to_npan("+12065551212")
    assert "2065551212"   === Number.to_npan("12065551212")
  end

  test "number normalizations" do
    assert "+12065551212" === Number.normalize("2065551212")
    assert "+12065551212" === Number.normalize("12065551212")
    assert "+18005551212" === Number.normalize("8005551212")
    assert "+96855556666" === Number.normalize("01196855556666")
  end
end
