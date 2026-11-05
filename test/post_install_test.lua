local t = dofile(arg[1] .. "/test/helpers.lua")

-- These tests run the hook's shell commands for real, against a miniature
-- archive that test/make_sdk.py lays out in a temporary directory.

local function quote(path)
  return "'" .. path:gsub("'", "'\\''") .. "'"
end

-- Runs a command, returning its output and whether it succeeded.
local function sh(command)
  local output = os.tmpname()
  local status = os.execute("(" .. command .. ") >" .. quote(output) .. " 2>&1")
  local text = t.read(output)
  os.remove(output)
  return text, status == 0 or status == true
end

local function check(command)
  local text, ok = sh(command)
  if not ok then
    error("command failed: " .. command .. "\n" .. text, 2)
  end
  return text
end

local stubs = {
  -- mise's cmd.exec raises an error when the command fails.
  cmd = { exec = check },
  file = {
    exists = function(path)
      local _, ok = sh("test -e " .. quote(path))
      return ok
    end,
  },
}

local function lines(text)
  local list = {}
  for line in text:gmatch("[^\n]+") do
    table.insert(list, line)
  end
  return list
end

-- Lays out an archive for `host` in a new directory, then installs it there.
local function install(host, omit)
  local root = check("mktemp -d"):gsub("%s+$", "")
  local flags = ""
  for _, entry in ipairs(omit or {}) do
    flags = flags .. " --omit " .. entry
  end
  check(
    "python3 -I "
      .. quote(t.plugin_dir .. "/test/make_sdk.py")
      .. " "
      .. quote(root)
      .. " "
      .. host
      .. flags
  )
  RUNTIME = { osType = host, archType = "amd64", pluginDirPath = t.plugin_dir }
  local ok, message = pcall(function()
    t.load("post_install", stubs):PostInstall({ rootPath = root })
  end)
  return root, ok, message
end

local function remove(root)
  check("rm -rf " .. quote(root))
end

for _, host in ipairs({ "darwin", "linux" }) do
  t.test(
    host .. ": keeps the native, device-tool, and ArkTS components",
    function()
      local root, ok, message = install(host)
      assert(ok, message)
      t.eq(
        lines(check("cd " .. quote(root) .. " && ls -A")),
        { "bin", "ets", "native", "toolchains" },
        "top level"
      )
      t.eq(
        check("cd " .. quote(root) .. "/native/llvm/bin && readlink clang++"),
        "clang\n",
        "clang++ link"
      )
      t.eq(
        check(quote(root) .. "/native/llvm/bin/clang++"),
        "clang\n",
        "clang++ output"
      )
      remove(root)
    end
  )

  t.test(host .. ": links hdc alone into bin/", function()
    local root, ok, message = install(host)
    assert(ok, message)
    local bin = quote(root .. "/bin")
    t.eq(lines(check("cd " .. bin .. " && ls -A")), { "hdc" }, "bin/")
    t.eq(
      check("cd " .. bin .. " && readlink hdc"),
      "../toolchains/hdc\n",
      "hdc link"
    )
    t.eq(check(bin .. "/hdc"), "hdc\n", "hdc output")
    remove(root)
  end)

  t.test(host .. ": fails when a component is missing", function()
    local root, ok, message = install(host, { "ets" })
    assert(not ok, "expected the install to fail")
    assert(
      tostring(message):find(
        "expected one ets component archive, found 0",
        1,
        true
      ),
      message
    )
    remove(root)
  end)

  t.test(host .. ": fails when toolchains/ has no hdc", function()
    local root, ok, message = install(host, { "hdc" })
    assert(not ok, "expected the install to fail")
    assert(
      tostring(message):find(
        "the installed SDK has no device connector at ",
        1,
        true
      ),
      message
    )
    remove(root)
  end)
end

t.done()
