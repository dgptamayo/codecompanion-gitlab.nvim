-- lua/codecompanion_gitlab/request_handler.lua
local lsp_client = require("codecompanion_gitlab.lsp_client")

local M = {}

-- Supported request types mapped to LSP methods
local request_methods = {
  completion = "textDocument/completion",
  hover = "textDocument/hover",
  -- Add additional LSP methods as needed
}

-- Prepares and sends a request to GitLab LSP and returns the response
function M.send_request(request_type, params)
  local method = request_methods[request_type]
  if not method then
    error("[codecompanion_gitlab] Unsupported request type: " .. tostring(request_type))
  end

  -- Format params according to LSP spec
  local lsp_params = M.format_params(request_type, params)

  -- Send request via LSP client
  local result = lsp_client.send_request(method, lsp_params)
  return result
end

-- Format request params depending on request type
function M.format_params(request_type, params)
  if request_type == "completion" then
    -- Typical completion params for LSP
    return {
      textDocument = { uri = params.uri },
      position = { line = params.line, character = params.character },
      context = params.context or {},
    }
  elseif request_type == "hover" then
    return {
      textDocument = { uri = params.uri },
      position = { line = params.line, character = params.character },
    }
  else
    -- Default passthrough
    return params
  end
end

return M
