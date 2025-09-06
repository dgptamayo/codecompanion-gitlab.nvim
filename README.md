# CodeCompanion GitLab Adapter

A custom adapter for CodeCompanion.nvim that integrates GitLab Duo AI-assisted code completions and chat features via the official GitLab Language Server Protocol (LSP).

## Overview

This adapter connects CodeCompanion to the existing GitLab LSP server (gitlab-ls), enabling AI-powered suggestions and chat by leveraging GitLab Duo’s capabilities indirectly through the GitLab LSP integration.

## Features

- Communicates with GitLab LSP server over stdio JSON-RPC.
- Supports key LSP requests including textDocument/completion and textDocument/hover.
- Transforms LSP responses to CodeCompanion-compatible formats.
- Allows flexible configuration for GitLab URL, token, and adapter options.

## Installation

Clone or place this adapter module in your Neovim runtime path, for example:
```
git clone https://your.repo.url/codecompanion-gitlab-adapter ~/.config/nvim/lua/codecompanion_gitlab
```

## Configuration
```
require("codecompanion").setup({
    opts = {
        language = "English",
        system_prompt = "",
    },
    strategies = {
        chat = {
            adapter = "gitlab_duo",
            roles = {
                llm = function(adapter)
                    return "CodeCompanion (" .. adapter.formatted_name .. ")"
                end,
                user = "Me",
            },
            keymaps = {
                submit = {
                    modes = { n = "<CR>" },
                    description = "Submit",
                    callback = function(chat)
                        chat:submit()
                    end,
                },
            },
        },
        inline = {
            adapter = "gitlab_duo",
        },
    },
    adapters = {
        gitlab_duo = function()
            return require("codecompanion_gitlab")
        end,
    },
})
```

## Usage
Once configured, CodeCompanion will route completion and chat requests through the GitLab LSP adapter, providing Duo-powered AI assistance directly inside Neovim.

## Troubleshooting

- Verify that gitlab-ls launches correctly and is reachable.
- Confirm your GitLab token has permissions for Duo features.
- Use Neovim's :checkhealth codecompanion command to identify setup problems.
- Enable debug logging in the adapter setup to gather more diagnostic info if needed.

## License
MIT License
