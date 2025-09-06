-- lua/codecompanion_gitlab/lsp_client.lua
local uv = vim.loop
local json = vim.fn.json_decode
local json_encode = vim.fn.json_encode
local api = vim.api

local M = {}

-- JSON-RPC state
local seq = 0
local requests = {}

-- Handle stdout from LSP server
local function on_stdout_read(err, chunk)
  if err then
    vim.notify("[codecompanion_gitlab] LSP stdout read error: " .. err, vim.log.levels.ERROR)
    return
  end
  if chunk then
    -- Accumulate parsing logic here for JSON-RPC messages (to be implemented)
    -- For simplicity, assuming chunk is a complete message (adjust for real use)
    local msg = vim.fn.json_decode(chunk)
    if msg and msg.id and requests[msg.id] then
      requests[msg.id](msg.result)
      requests[msg.id] = nil
    end
  end
end

-- Starts the GitLab LSP server as a child process and sets up pipes
function M.start(opts)
  if M.proc then
    return
  end

  opts = opts or {}
  local cmd = opts.cmd or {"gitlab-ls", "--stdio"} -- Adjust if different

  local stdout_pipe = uv.new_pipe(false)
  local stdin_pipe = uv.new_pipe(false)

  local handle, pid
  handle, pid = uv.spawn(
    cmd[1],
    {
      args = {unpack(cmd, 2)},
      stdio = {stdin_pipe, stdout_pipe, nil},
    },
    function(code, signal)
      vim.schedule(function()
        vim.notify(string.format("[codecompanion_gitlab] GitLab LSP exited with code %d, signal %d", code, signal), vim.log.levels.ERROR)
      end)
      handle:close()
      M.proc = nil
    end
  )

  if not handle then
    vim.notify("[codecompanion_gitlab] Failed to start GitLab LSP server", vim.log.levels.ERROR)
    return
  end

  -- Start reading from stdout pipe
  stdout_pipe:read_start(on_stdout_read)

  M.proc = handle
  M.stdin = stdin_pipe
end

-- Sends a JSON-RPC request and returns a promise-like handler
function M.send_request(method, params)
  seq = seq + 1
  local id = seq
  local req_obj = {
    jsonrpc = "2.0",
    id = id,
    method = method,
    params = params,
  }
  local req_str = json_encode(req_obj)
  local out_str = string.format("Content-Length: %d\r\n\r\n%s", #req_str, req_str)

  M.stdin:write(out_str)

  local co = coroutine.running()
  requests[id] = function(result)
    coroutine.resume(co, result)
  end
  return coroutine.yield()
end

return M

