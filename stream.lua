require 'sequence'

Stream = {}
  local function _new_stream (f)
    return {
      filter = Stream.filter,
      map = Stream.map,
      process = Stream.process,
      to_sequence = Stream.to_sequence,
      _iter = coroutine.wrap(f)
    }
  end

function Stream.create (obj)
  if type(obj) == 'function' then
    return _new_stream(function ()
      local resume, val = obj()
      while resume do
        coroutine.yield(val)
        resume, val = obj()
      end
    end)

  else  -- assuming a sequence of some sort
    return _new_stream(function ()
      for i = 1, Sequence.size(obj) do
        coroutine.yield(obj[i])
      end
    end)
  end
end

function Stream:process ()
  return self._iter
end

function Stream:to_sequence ()
  local s = Sequence.new()
  for i in self:process() do
    s = s:prepend(i)
  end
  return s:reverse()
end

function Stream:map (f)
  return _new_stream(function ()
    for i in self:process() do
      coroutine.yield(f(i))
    end
  end)
end

function Stream:filter (f)
  return _new_stream(function ()
    for i in self:process() do
      if f(i) then
        coroutine.yield(i)
      end
    end
  end)
end
