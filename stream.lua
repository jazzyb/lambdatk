require 'sequence'

-- Define the Stream methods
Stream = {}
  local function _new_stream (f)
    return {
      cycle = Stream.cycle,
      filter = Stream.filter,
      get = Stream.get,
      map = Stream.map,
      process = Stream.process,
      reduce = Stream.reduce,
      to_sequence = Stream.to_sequence,
      _iter = coroutine.wrap(f)
    }
  end

-- Define table.unpack() for old Lua
local _unpack = table.unpack or unpack

-- Return a Stream from a function or sequence.  If the argument is a
-- function, the function must return ```[true | false], value```.  If the
-- first return value is false, then this signifies that the Stream is
-- complete.
function Stream.create (arg)
  if type(arg) == 'function' then
    return _new_stream(function ()
      local resume, val = arg()
      while resume do
        coroutine.yield(val)
        resume, val = arg()
      end
    end)

  else  -- assuming a sequence of some sort
    return _new_stream(function ()
      for i = 1, Sequence.size(arg) do
        coroutine.yield(arg[i])
      end
    end)
  end
end

-- Returns a generator for the Stream.  Used in for-loops:
--    for i in stream:process() do print(i) end
function Stream:process ()
  return self._iter
end

-- Return the next value(s) from the Stream
--
-- NOTE:  Stream:get()'s behavior is undefined if the Stream has nil values in
-- it.  If the Stream contains nil values, either filter them out first or
-- call process() instead.
function Stream:get (count)
  local s = {}
  local count = count or 1
  for i = 1, count do
    s[#s + 1] = self:process()()
  end
  return _unpack(s)
end

-- Convert and return the Stream as a Sequence
function Stream:to_sequence ()
  local s = Sequence.new()
  for i in self:process() do
    s = s:prepend(i)
  end
  return s:reverse()
end

-- Returns a Stream that will cycle through its output indefinitely
function Stream:cycle ()
  return _new_stream(function ()
    -- run through the stream once collecting the output
    local cache = Sequence.new()
    for i in self:process() do
      cache = cache:prepend(i)
      coroutine.yield(i)
    end

    -- run through the previous output indefinitely
    local i = 0
    cache = cache:reverse()
    while true do
      coroutine.yield(cache[i + 1])
      i = (i + 1) % cache:size()
    end
  end)
end

-- Return a Stream that acts like a map function
function Stream:map (f)
  return _new_stream(function ()
    for i in self:process() do
      coroutine.yield(f(i))
    end
  end)
end

-- Return a Stream that acts like a filter function
function Stream:filter (f)
  return _new_stream(function ()
    for i in self:process() do
      if f(i) then
        coroutine.yield(i)
      end
    end
  end)
end

-- Return the accumulation from calling reduce on the Stream
function Stream:reduce (arg1, arg2)
  local acc, f
  if arg2 == nil then
    acc, f = self:get(), arg1
  else
    acc, f = arg1, arg2
  end

  for i in self:process() do
    acc = f(i, acc)
  end
  return acc
end
