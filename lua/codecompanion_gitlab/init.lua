-- lua/codecompanion_gitlab/init.lua
local M = {}

local lsp_client = require("codecompanion_gitlab.lsp_client")
local request_handler = require("codecompanion_gitlab.request_handler")
local response_parser = require("codecompanion_gitlab.response_parser")

function M.setup(opts)
  opts = opts or {}

  lsp_client.start(opts)

  require("codecompanion").register_adapter({
    name = "gitlab",
    description = "GitLab Duo adapter via GitLab LSP integration",
    adapter = M,
    opts = opts,
  })
end

-- Enhanced send_request to handle parsing
function M.send_request(request_type, params)
  local ok, lsp_response = pcall(request_handler.send_request, request_type, params)
  if not ok then
    return nil, "[codecompanion_gitlab] Error sending request: " .. tostring(lsp_response)
  end

  local parsed_response

  if request_type == "completion" then
    parsed_response = response_parser.parse_completion_response(lsp_response)
  elseif request_type == "hover" then
    parsed_response = response_parser.parse_hover_response(lsp_response)
  else
    -- Default: pass through the raw response
    parsed_response = lsp_response
  end

  return parsed_response
end

return M
