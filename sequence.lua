-- Define Sequence class and methods
Sequence = {}
  local function _init_seq_methods (seq)
    seq.concat = Sequence.concat
    seq.copy = Sequence.copy
    seq.filter = Sequence.filter
    seq.map = Sequence.map
    seq.prepend = Sequence.prepend
    seq.reduce = Sequence.reduce
    seq.reverse = Sequence.reverse
    seq.size = Sequence.size
    seq.split = Sequence.split
    seq.subseq = Sequence.subseq
  end

-- Define table.pack() if using old Lua
local pack = table.pack
if not pack then
  pack = function (...)
    local arg = {...}
    arg.n = select('#', ...)
    return arg
  end
end

-- Sequence.new can take arguments in two ways:
-- (1) Sequence.new(vargs...)
-- (2) Sequence.new(count, func)
-- In the first, any number and kind of items can be provided.  A new Sequence
-- will be constructed with those items in the order given.
-- In the second, the second argument is a function that takes a single number
-- as argument (the index).  This function will be called 'count' times and
-- will return the next item for the sequence.
function Sequence.new (...)
  local args = pack(...)
  if args.n == 2 and type(args[1]) == 'number' and type(args[2]) == 'function' then
    local ret, count, f = {}, args[1], args[2]
    for i = 1, count do
      ret[i] = f(i)
    end
    ret.n = count
    args = ret
  end
  _init_seq_methods(args)
  return args
end

-- Return the size of the Sequence.  Since we want these functions to work on
-- any table sequence, not just Sequence instances -- if there is no length
-- variable, then return #table.
function Sequence.size (self)
  return self.n or #self
end

-- Returns a new Sequence generated by calling 'f' for each item in 'self'
function Sequence.map (self, f)
  return Sequence.new(Sequence.size(self), function (i)
    return f(self[i])
  end)
end

-- Returns a "reduced value" for the Sequence.  May be called in two different
-- ways:
-- (1) Sequence.reduce(self, acc, func)
-- (2) Sequence.reduce(self, func)
-- In the first, 'func' is a function which takes two arguments:  The first is
-- an item from 'self', and the second is an "accumulator".  The function will
-- return the next accumulator.
-- The second manner of calling the function is the same as the first except
-- the first item in 'self' will be treated as the first accumulator variable.
function Sequence.reduce (self, ...)
  local args = pack(...)
  local start, acc, f
  if args.n == 1 and type(args[1]) == 'function' then
    start, acc, f = 2, self[1], args[1]
  elseif args.n == 2 and type(args[2]) == 'function' then
    start, acc, f = 1, args[1], args[2]
  end

  for i = start, Sequence.size(self) do
    acc = f(self[i], acc)
  end
  return acc
end

-- Returns a new Sequence limited to the items in 'self' for which 'f' returns
-- true
function Sequence.filter (self, f)
  local ret = {}
  local count = 0
  for i = 1, Sequence.size(self) do
    if f(self[i], i) then
      ret[count + 1] = self[i]
      count = count + 1
    end
  end
  ret.n = count
  _init_seq_methods(ret)
  return ret
end

-- Returns a subsequence of 'self' from indices start to finish, inclusive
function Sequence.subseq (self, start, finish)
  if finish == nil or finish == -1 then
    finish = Sequence.size(self)
  end

  return Sequence.filter(self, function (_, idx)
    return (idx >= start and idx <= finish)
  end)
end

-- Returns a copy of 'self'
function Sequence.copy (self)
  return Sequence.subseq(self, 1)
end

-- Returns two values:  the first item in 'self' and the rest of 'self'
function Sequence.split (self)
  return self[1], Sequence.subseq(self, 2)
end

-- Returns a new Sequence with 'head' prepended to 'self'
function Sequence.prepend (self, head)
  return Sequence.new(Sequence.size(self) + 1, function (i)
    if i == 1 then
      return head
    else
      return self[i - 1]
    end
  end)
end

-- Returns 'seq' concatenated to the end of 'self'
function Sequence.concat (self, seq)
  local ret = Sequence.copy(self)
  for i = 1, Sequence.size(seq) do
    ret[ret.n + 1] = seq[i]
    ret.n = ret.n + 1
  end
  return ret
end

-- Returns 'self' reversed
function Sequence.reverse (self)
  local size = Sequence.size(self)
  return Sequence.new(size, function (i)
    return self[size - i + 1]
  end)
end
