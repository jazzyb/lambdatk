require 'sequence'
LuaUnit = require 'luaunit'

TestSequence = {}
  function TestSequence:test_new_sequence ()
    local s = Sequence.new(1, 2, 3, 4, 5)
    for i = 1, 5 do assertEquals(s[i], i) end
  end

  function TestSequence:test_new_sequence_with_nils ()
    local s = Sequence.new(1, nil, 3, nil, 5)
    for i = 1, 5 do
      if i % 2 == 1 then
        assertEquals(s[i], i)
      else
        assertEquals(s[i], nil)
      end
    end
  end

  function TestSequence:test_new_sequence_with_function ()
    local s = Sequence.new(5, function (i) return i * i end)
    for i = 1, 5 do assertEquals(s[i], i * i) end
  end

  function TestSequence:test_size ()
    local s = Sequence.new(1, 2, 3, 4, 5)
    assertEquals(s:size(), 5)
    assertEquals(Sequence.size{1,2,3}, 3)
    local s = Sequence.new(1, 2, nil, 4, 5)
    assertEquals(s:size(), 5)
  end

  function TestSequence:test_map ()
    local f = function (x) return x * x end
    local s = Sequence.new(1, 2, 3, 4, 5):map(f)
    local t = Sequence.map({1, 2, 3, 4, 5}, f)
    for i = 1, 5 do
      assertEquals(s[i], i * i)
      assertEquals(t[i], i * i)
    end
  end

  function TestSequence:test_reduce ()
    local f = function (x, sum) return x + sum end
    local s = Sequence.new(2, 3, 4):reduce(1, f)
    assertEquals(s, 10)
    local t = Sequence.reduce({2, 3, 4}, 1, f)
    assertEquals(t, 10)
  end

  function TestSequence:test_reduce_without_accumulator ()
    local f = function (s, str) return str .. ':' .. s end
    local s = Sequence.new('a', 'b', 'c', 'd', 'e'):reduce(f)
    assertEquals(s, 'a:b:c:d:e')
    local t = Sequence.reduce({'a', 'b', 'c', 'd', 'e'}, f)
    assertEquals(t, 'a:b:c:d:e')
  end

  function TestSequence:test_filter ()
    local f = function (x) return x % 2 == 1 end
    local s = Sequence.new(1, 2, 3, 4, 5):filter(f)
    assertEquals(s.n, 3)
    local t = Sequence.filter({1, 2, 3, 4, 5}, f)
    assertEquals(#t, 3)
    for i = 1, 3 do
      assertEquals(s[i], 2 * (i - 1) + 1)
      assertEquals(t[i], 2 * (i - 1) + 1)
    end
  end

  function TestSequence:test_subseq ()
    local s = Sequence.new(1, 2, 3, 4, 5):subseq(3)
    assertEquals(s.n, 3)
    local t = Sequence.subseq({1, 2, 3, 4, 5}, 3)
    assertEquals(#t, 3)
    for i = 1, 3 do
      assertEquals(s[i], i + 2)
      assertEquals(t[i], i + 2)
    end
  end

  function TestSequence:test_subseq_with_finish ()
    local s = Sequence.new(1, 2, 3, 4, 5):subseq(3, 4)
    assertEquals(s.n, 2)
    local t = Sequence.subseq({1, 2, 3, 4, 5}, 3, 4)
    assertEquals(#t, 2)
    for i = 1, 2 do
      assertEquals(s[i], i + 2)
      assertEquals(t[i], i + 2)
    end
  end

  function TestSequence:test_copy ()
    local t = {1, 2, 3, 4, 5}
    local s = Sequence.copy(t)
    for i = 1, #t do assertEquals(s[i], t[i]) end
  end

  function TestSequence:test_split ()
    local head, tail = Sequence.new(1, 2, 3):split()
    assertEquals(head, 1)
    assertEquals(tail.n, 2)
    assertEquals(tail[1], 2)
    assertEquals(tail[2], 3)

    head, tail = Sequence.split(tail)
    assertEquals(head, 2)
    assertEquals(tail.n, 1)
    assertEquals(tail[1], 3)
  end

  function TestSequence:test_prepend ()
    local s = Sequence.new(1, 2, 3):prepend(0)
    assertEquals(s.n, 4)
    for i = 1, 4 do assertEquals(s[i], i - 1) end

    local t = Sequence.prepend({1, 2, 3}, 0)
    assertEquals(#t, 4)
    for i = 1, 4 do assertEquals(t[i], i - 1) end
  end

  function TestSequence:test_concat ()
    local s = Sequence.new(1, 2, 3):concat{4, 5, 6}
    assertEquals(s.n, 6)
    for i = 1, 6 do assertEquals(s[i], i) end
  end

  function TestSequence:test_reverse ()
    local s = Sequence.new(3, 2, 1):reverse()
    local t = Sequence.reverse{3, 2, 1}
    for i = 1, 3 do
      assertEquals(s[i], i)
      assertEquals(t[i], i)
    end
  end

os.exit(LuaUnit:run())
