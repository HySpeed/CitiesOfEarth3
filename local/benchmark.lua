---@alias benchmark.units
---| 'seconds'
---| 'milliseconds'
---| 'microseconds'
---| 'nanoseconds'

local units = {
  ['seconds'] = 1,
  ['milliseconds'] = 1000,
  ['microseconds'] = 1000000,
  ['nanoseconds'] = 1000000000
}

---@param unit benchmark.units
---@param decPlaces integer
---@param n integer
---@param f function
---@param ... any
local function benchmark(unit, decPlaces, n, f, ...)
  local elapsed = 0
  local multiplier = units[unit]
  for _ = 1, n do
    local now = os.clock()
    f(...)
    elapsed = elapsed + (os.clock() - now)
  end
  ---@cast n +string, -integer
  print(string.format(
    'Benchmark results: %d function calls | %.'
    .. decPlaces
    .. 'f %s elapsed | %.'
    .. decPlaces
    .. 'f %s avg execution time.',
    n, elapsed * multiplier, unit, (elapsed / n) * multiplier, unit)
  )
end

return benchmark
