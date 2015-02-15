require 'stream'
LuaUnit = require 'luaunit'

TestStream = {}
  function TestStream:test_create ()
    local t = {1, 2, 3, 4, 5}
    local s = Stream.create(t)
    for i in s:process() do
      assertEquals(i, t[i])
    end
  end

  function TestStream:test_create_with_function ()
    -- ensure that the function is only being called when a value is needed
    local i = 0
    local f = function ()
      i = i + 1
      return true, i
    end

    local s = Stream.create(f)
    assertEquals(i, 0)
    assertEquals(s:get(), 1)
    assertEquals(i, 1)
    a, b = s:get(2)
    assertEquals(a, 2)
    assertEquals(b, 3)
    assertEquals(i, 3)
  end

  function TestStream:test_to_sequence ()
    local t = {1, 2, 3, 4, 5}
    local s = Stream.create(t):to_sequence()
    for i = 1, #t do assertEquals(s[i], t[i]) end
  end

  function TestStream:test_cycle ()
    local s = Stream.create({0, 1}):cycle()
    for i = 0, 9 do assertEquals(s:get(), i % 2) end
  end

  function TestStream:test_map ()
    local s = Stream.create({1, 2, 3, 4, 5}):map(function (x) return x * x end)
    for i = 1, 5 do assertEquals(s:get(), i * i) end
    -- ensure the stream is complete
    for i in s:process() do assertTrue(false) end
  end

  function TestStream:test_filter ()
    local s = Stream.create({1, 2, 3, 4, 5}):filter(function (x) return x % 2 == 1 end)
    for i = 1, 3 do assertEquals(s:get(), 2 * (i - 1) + 1) end
    -- ensure the stream is complete
    for i in s:process() do assertTrue(false) end
  end

  function TestStream:test_reduce ()
    local f = function (x, sum) return x + sum end
    local s = Stream.create({2, 3, 4}):reduce(1, f)
    assertEquals(s, 10)
  end

  function TestStream:test_reduce_without_accumulator ()
    local f = function (s, str) return str .. ':' .. s end
    local s = Stream.create({'a', 'b', 'c', 'd', 'e'}):reduce(f)
    assertEquals(s, 'a:b:c:d:e')
  end

os.exit(LuaUnit:run())
