-- lua/codecompanion_gitlab/init.lua
local lsp_client = require("codecompanion_gitlab.lsp_client")
local request_handler = require("codecompanion_gitlab.request_handler")
local response_parser = require("codecompanion_gitlab.response_parser")
local utils = require("codecompanion.utils.adapters")  -- hypothetical utility import if needed

local M = {
  name = "gitlab_duo",
  formatted_name = "GitLab Duo",
  env = {},
  headers = {},
  parameters = {},
  body = {},
  raw = {},
  opts = {},
}

-- Setup handler: start GitLab LSP server
function M.handlers.setup(self)
  -- Start the LSP, return true on success to continue
  local ok, err = pcall(function() lsp_client.start(self.opts) end)
  if not ok then
    vim.notify("[codecompanion_gitlab] Setup failed: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end
  return true
end

-- Form parameters for LSP request (stub for now)
function M.handlers.form_parameters(self, params)
  -- Return params unmodified or adapt as needed
  return params
end

-- Form messages array into LSP-compatible structure (completion request context)
function M.handlers.form_messages(self, messages)
  -- Convert CodeCompanion chat messages to LSP parameters
  -- For example, use latest message's text and cursor position to build LSP completion params
  -- This will depend on message structure; here's a basic idea:
  local last_msg = messages[#messages]
  local lsp_params = {
    textDocument = { uri = last_msg.uri or "" },
    position = { line = last_msg.line or 0, character = last_msg.character or 0 },
    context = {},
  }
  return lsp_params
end

-- Process chat outputs from LSP response
function M.handlers.chat_output(self, data)
  if not data then
    return { status = "error", output = { content = "No response from GitLab LSP" } }
  end

  local completions = response_parser.parse_completion_response(data)
  if #completions == 0 then
    return { status = "error", output = { content = "No completions returned" } }
  end

  -- Join completion labels or use text as output content
  local content = ""
  for _, item in ipairs(completions) do
    content = content .. (item.insertText or item.label) .. "\n"
  end

  return {
    status = "success",
    output = {
      content = content,
    },
  }
end

-- Process inline output from LSP response
function M.handlers.inline_output(self, data, context)
  if not data then
    return nil
  end

  local completions = response_parser.parse_completion_response(data)
  if #completions == 0 then
    return nil
  end

  -- Return the first insertText or label for inline insertion
  return completions[1].insertText or completions[1].label
end

-- Optional on_exit handler to catch errors
function M.handlers.on_exit(self, data)
  if data and data.status and data.status >= 400 then
    vim.notify("[codecompanion_gitlab] Request error: " .. (data.body or ""), vim.log.levels.ERROR)
  end
end

-- Optional teardown handler for cleanup
function M.handlers.teardown(self)
  -- Currently no teardown logic needed
end

return M

