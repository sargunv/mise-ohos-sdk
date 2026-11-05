-- A small harness for running the plugin's hooks outside mise. Each test file
-- loads this with the plugin directory as its argument:
--
--   local t = dofile(arg[1] .. "/test/helpers.lua")

local t = {}

t.plugin_dir = assert(arg[1], "pass the plugin directory as the first argument")

local failures = 0
local modules = { "cmd", "file", "http", "strings" }

--- Loads a hook into a fresh PLUGIN table, with `stubs` standing in for the
--- modules mise provides. A hook requires its modules when it loads, so the
--- stubs must be in place first.
function t.load(hook, stubs)
  for _, name in ipairs(modules) do
    package.loaded[name] = nil
  end
  for name, stub in pairs(stubs or {}) do
    package.loaded[name] = stub
  end
  PLUGIN = {}
  assert(loadfile(t.plugin_dir .. "/hooks/" .. hook .. ".lua"))()
  return PLUGIN
end

--- mise's strings module, as far as the hooks use it.
t.strings = {
  trim_space = function(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
  end,
}

function t.read(path)
  local handle = assert(io.open(path, "rb"))
  local contents = handle:read("*a")
  handle:close()
  return contents
end

local function show(value)
  if type(value) == "table" then
    local parts = {}
    for _, item in ipairs(value) do
      table.insert(parts, show(item))
    end
    for key, item in pairs(value) do
      if type(key) ~= "number" then
        table.insert(parts, tostring(key) .. " = " .. show(item))
      end
    end
    return "{ " .. table.concat(parts, ", ") .. " }"
  end
  if type(value) == "string" then
    return string.format("%q", value)
  end
  return tostring(value)
end

local function same(left, right)
  if type(left) ~= "table" or type(right) ~= "table" then
    return left == right
  end
  for key, value in pairs(left) do
    if not same(value, right[key]) then
      return false
    end
  end
  for key in pairs(right) do
    if left[key] == nil then
      return false
    end
  end
  return true
end

function t.eq(actual, expected, what)
  if not same(actual, expected) then
    error(
      (what or "value")
        .. ": expected "
        .. show(expected)
        .. ", got "
        .. show(actual),
      2
    )
  end
end

--- Asserts that `fn` raises an error whose message contains `fragment`.
function t.raises(fragment, fn)
  local ok, message = pcall(fn)
  if ok then
    error("expected an error containing " .. show(fragment), 2)
  end
  if not tostring(message):find(fragment, 1, true) then
    error(
      "expected an error containing "
        .. show(fragment)
        .. ", got "
        .. show(tostring(message)),
      2
    )
  end
end

function t.test(name, fn)
  local ok, message = xpcall(fn, debug.traceback)
  if ok then
    print("ok   " .. name)
  else
    failures = failures + 1
    print("FAIL " .. name .. "\n" .. tostring(message))
  end
end

function t.done()
  if failures > 0 then
    os.exit(1)
  end
end

return t
