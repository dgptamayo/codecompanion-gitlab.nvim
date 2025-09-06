-- lua/codecompanion_gitlab/response_parser.lua
local M = {}

-- Parses LSP completion response into CodeCompanion format
function M.parse_completion_response(lsp_result)
  if not lsp_result or not lsp_result.items then
    return {}
  end

  local completions = {}

  for _, item in ipairs(lsp_result.items) do
    table.insert(completions, {
      label = item.label,
      kind = item.kind, -- can be mapped to CodeCompanion kinds if needed
      detail = item.detail,
      documentation = item.documentation and (type(item.documentation) == "table" and item.documentation.value or item.documentation) or nil,
      insertText = item.insertText or item.label,
      filterText = item.filterText or item.label,
      sortText = item.sortText,
    })
  end

  return completions
end

-- Parses LSP hover response into CodeCompanion format
function M.parse_hover_response(lsp_result)
  if not lsp_result or not lsp_result.contents then
    return nil
  end

  local contents = lsp_result.contents

  if type(contents) == "table" then
    -- Extract text content from MarkedString or MarkupContent
    if contents.value then
      return contents.value
    elseif vim.tbl_islist(contents) then
      local combined = ""
      for _, c in ipairs(contents) do
        if type(c) == "string" then
          combined = combined .. c .. "\n"
        elseif c.value then
          combined = combined .. c.value .. "\n"
        end
      end
      return combined
    else
      return tostring(contents)
    end
  elseif type(contents) == "string" then
    return contents
  end

  return nil
end

return M
