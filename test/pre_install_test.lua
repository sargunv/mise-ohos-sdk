local t = dofile(arg[1] .. "/test/helpers.lua")

local RELEASES = "https://repo.huaweicloud.com/openharmony/os/"

-- The URLs the last run of the hook fetched.
local requested

-- Runs the hook as a host of the given OS and architecture. `responses` maps a
-- URL to the response the stub returns for it.
local function pre_install(host, version, responses, python)
  RUNTIME =
    { osType = host.os, archType = host.arch, pluginDirPath = t.plugin_dir }
  requested = {}
  local plugin = t.load("pre_install", {
    cmd = {
      exec = function(command)
        assert(
          command:find("command -v python3", 1, true),
          "unexpected command: " .. command
        )
        return python == false and "no\n" or "yes\n"
      end,
    },
    http = {
      get = function(options)
        table.insert(requested, options.url)
        return responses[options.url] or { status_code = 404, body = "" }
      end,
    },
    strings = t.strings,
  })
  return plugin:PreInstall({ version = version })
end

local hosts = {
  { os = "darwin", arch = "arm64", archive = "L2-SDK-MAC-M1-PUBLIC.tar.gz" },
  { os = "darwin", arch = "amd64", archive = "ohos-sdk-mac-public.tar.gz" },
  {
    os = "linux",
    arch = "amd64",
    archive = "ohos-sdk-windows_linux-public.tar.gz",
  },
  {
    os = "linux",
    arch = "x86_64",
    archive = "ohos-sdk-windows_linux-public.tar.gz",
  },
}

for _, host in ipairs(hosts) do
  t.test(
    "downloads " .. host.archive .. " on " .. host.os .. " " .. host.arch,
    function()
      local url = RELEASES .. "6.1-Release/" .. host.archive
      -- The publisher's digest file ends in a newline, which the hook trims.
      local result = pre_install(host, "6.1", {
        [url .. ".sha256"] = { status_code = 200, body = "7d54a52d  \n" },
      })
      t.eq(requested, { url .. ".sha256" }, "requested URLs")
      t.eq(
        result,
        { version = "6.1", url = url, sha256 = "7d54a52d" },
        "result"
      )
    end
  )
end

t.test("refuses Linux on architectures the SDK is not built for", function()
  t.raises("published for x86_64 Linux, not arm64", function()
    pre_install({ os = "linux", arch = "arm64" }, "6.1", {})
  end)
end)

t.test("refuses Windows", function()
  t.raises("supports Linux and macOS hosts", function()
    pre_install({ os = "windows", arch = "amd64" }, "6.1", {})
  end)
end)

t.test("checks for python3 before downloading anything", function()
  t.raises("python3 is required", function()
    pre_install(hosts[1], "6.1", {}, false)
  end)
  t.eq(requested, {}, "requested URLs")
end)

t.test("names the version and URL when a release has no SDK", function()
  t.raises(
    "no OpenHarmony SDK for version 9.9: HTTP 404 for "
      .. RELEASES
      .. "9.9-Release/L2-SDK-MAC-M1-PUBLIC.tar.gz.sha256",
    function()
      pre_install(hosts[1], "9.9", {})
    end
  )
end)

t.done()
