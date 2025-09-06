-- lua/codecompanion_gitlab/init.lua
local lsp_client = require("codecompanion_gitlab.lsp_client")
local request_handler = require("codecompanion_gitlab.request_handler")
local response_parser = require("codecompanion_gitlab.response_parser")

local M = {}
M.formatted_name = "GitLab Duo"

-- Setup function to register the adapter with CodeCompanion
function M.setup(opts)
  opts = opts or {}

  -- Start or attach to the GitLab LSP server
  lsp_client.start(opts)

  -- Register adapter with CodeCompanion if needed (optional)
  -- CodeCompanion automatic registration usually happens externally
end

-- Enhanced send_request that always returns a valid table or string
function M.send_request(request_type, params)
  local ok, lsp_response = pcall(request_handler.send_request, request_type, params)
  if not ok or not lsp_response then
    return {}, "[codecompanion_gitlab] Error: failed to get response"
  end

  local parsed_response

  if request_type == "completion" then
    parsed_response = response_parser.parse_completion_response(lsp_response) or {}
  elseif request_type == "hover" then
    parsed_response = response_parser.parse_hover_response(lsp_response) or ""
  else
    parsed_response = lsp_response or {}
  end

  return parsed_response
end

return M

