---@meta http

---@class HttpResponse
---@field status_code integer
---@field body string

local http = {}

---@param opts {url: string}
---@return HttpResponse response
---@return string? err
function http.get(opts) end

return http
