---@meta
-- LuaCATS definitions for the parts of mise's vfox runtime this plugin uses, so
-- lua-language-server can check the hooks. See https://mise.jdx.dev/tool-plugin-development.html.

---@class Runtime
---@field osType "darwin"|"linux"|"windows"
---@field archType string For example "amd64" or "arm64"
---@field pluginDirPath string
RUNTIME = {}

---@class AvailableVersion
---@field version string
---@field note? string

---@class PreInstallCtx
---@field version string

---@class PreInstallResult
---@field version string
---@field url string
---@field sha256? string

---@class PostInstallCtx
---@field rootPath string

---@class EnvKeysCtx
---@field path string
---@field version string

---@class EnvKey
---@field key string
---@field value string

---@class Plugin
---@field name string
---@field version string
---@field description string
---@field author string
---@field homepage string
---@field license string
---@field Available fun(self: Plugin, ctx: table): AvailableVersion[]
---@field PreInstall fun(self: Plugin, ctx: PreInstallCtx): PreInstallResult
---@field PostInstall fun(self: Plugin, ctx: PostInstallCtx)
---@field EnvKeys fun(self: Plugin, ctx: EnvKeysCtx): EnvKey[]
PLUGIN = {}
