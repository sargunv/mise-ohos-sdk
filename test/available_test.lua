local t = dofile(arg[1] .. "/test/helpers.lua")

local INDEX = "https://repo.huaweicloud.com/openharmony/os/"

local function available(response, err)
  local requested = {}
  local plugin = t.load("available", {
    http = {
      get = function(options)
        table.insert(requested, options.url)
        return response, err
      end,
    },
  })
  return plugin:Available({}), requested
end

local function versions(result)
  local list = {}
  for _, entry in ipairs(result) do
    table.insert(list, entry.version)
  end
  return list
end

t.test("lists each release in the index, newest first", function()
  -- A snapshot of the index. It also holds betas, LTS releases, and unversioned
  -- directories, none of which publish the SDK archives this plugin installs.
  local body = t.read(t.plugin_dir .. "/test/fixtures/releases.html")
  local result, requested = available({ status_code = 200, body = body })
  t.eq(requested, { INDEX }, "requested URLs")
  t.eq(versions(result), {
    "7.0",
    "6.1",
    "6.0.0.2",
    "6.0.0.1",
    "6.0",
    "5.1.0",
    "5.0.3",
    "5.0.2",
    "5.0.1",
    "5.0.0",
    "4.1.4",
    "4.1.3",
    "4.1.2",
    "4.1.1",
    "4.1",
    "4.0.4",
    "4.0.3",
    "4.0.2",
    "4.0.1",
    "4.0",
    "3.2",
    "3.1",
  }, "versions")
end)

t.test("compares versions by component, not as text", function()
  local body = table.concat({
    '<a href="10.0-Release/">',
    '<a href="9.0.10-Release/">',
    '<a href="9.0.9-Release/">',
    '<a href="9.0-Release/">',
    '<a href="9.0.0.1-Release/">',
  })
  t.eq(
    versions(available({ status_code = 200, body = body })),
    { "10.0", "9.0.10", "9.0.9", "9.0.0.1", "9.0" },
    "versions"
  )
end)

t.test("lists a release once when the index links it twice", function()
  local body =
    '<a href="6.1-Release/">6.1-Release/</a><a href="6.1-Release/" title="6.1-Release">'
  t.eq(
    versions(available({ status_code = 200, body = body })),
    { "6.1" },
    "versions"
  )
end)

t.test("fails when the index is unreachable", function()
  t.raises("could not list OpenHarmony releases: timed out", function()
    available(nil, "timed out")
  end)
  t.raises("could not list OpenHarmony releases: HTTP 503", function()
    available({ status_code = 503, body = "" })
  end)
end)

t.test("fails when the index lists no releases", function()
  t.raises("no OpenHarmony releases found at " .. INDEX, function()
    available({ status_code = 200, body = '<a href="6.1-LTS/">' })
  end)
end)

t.done()
