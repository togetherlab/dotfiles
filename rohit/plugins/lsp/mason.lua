return {
    "williamboman/mason.nvim",
    lazy = false,
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "neovim/nvim-lspconfig",
    },
    config = function()
        -- import mason and mason_lspconfig
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        local mason_tool_installer = require("mason-tool-installer")

        -- NOTE: Moved from lspconfig.lua
        -- import lspconfig plugin
        local lspconfig = require("lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")             -- import cmp-nvim-lsp plugin
        local capabilities = cmp_nvim_lsp.default_capabilities() -- used to enable autocompletion (assign to every lsp server config)

        -- enable mason and configure icons
        mason.setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        mason_lspconfig.setup({
            -- servers for mason to install
            ensure_installed = {
                "lua_ls",
                "ts_ls",
                "html",
                "cssls",
                "tailwindcss",
                "gopls",
                "emmet_ls",
                "emmet_language_server",
                "eslint",
                "marksman",
            },
            -- auto install configured servers (with lspconfig)
            automatic_installation = true,
        })

        mason_tool_installer.setup({
            ensure_installed = {
                "prettier", -- prettier formatter
                "stylua",   -- lua formatter
                "isort",    -- python formatter
                "pylint",
                "clangd",
                { 'eslint_d', version = '13.1.2' },
            },
        })

        -- NOTE: Moved from lspconfig.lua
        --
        mason_lspconfig.setup_handlers({
            -- default handler for installed servers
            function(server_name)
                lspconfig[server_name].setup({
                    capabilities = capabilities,
                })
            end,
            ["emmet_ls"] = function()
                -- configure emmet language server
                lspconfig["emmet_ls"].setup({
                    capabilities = capabilities,
                    filetypes = {
                        "html",
                        "typescriptreact",
                        "javascriptreact",
                        "css",
                        "sass",
                        "scss",
                        "less",
                        "svelte",
                    },
                })
            end,
            ["lua_ls"] = function()
                -- configure lua server (with special settings)
                lspconfig["lua_ls"].setup({
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            -- make the language server recognize "vim" global
                            diagnostics = {
                                globals = { "vim" },
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                            workspace = {
                                -- make language server aware of run time files
                                library = {
                                    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                                    [vim.fn.stdpath("config") .. "/lua"] = true,
                                },
                            },
                        },
                    },
                })
            end,
            ["emmet_language_server"] = function()
                lspconfig.emmet_language_server.setup({
                    filetypes = {
                        "css",
                        "eruby",
                        "html",
                        "javascript",
                        "javascriptreact",
                        "less",
                        "sass",
                        "scss",
                        "pug",
                        "typescriptreact",
                    },
                    -- Read more about this options in the [vscode docs](https://code.visualstudio.com/docs/editor/emmet#_emmet-configuration).
                    -- **Note:** only the options listed in the table are supported.
                    init_options = {
                        ---@type table<string, string>
                        includeLanguages = {},
                        --- @type string[]
                        excludeLanguages = {},
                        --- @type string[]
                        extensionsPath = {},
                        --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/preferences/)
                        preferences = {},
                        --- @type boolean Defaults to `true`
                        showAbbreviationSuggestions = true,
                        --- @type "always" | "never" Defaults to `"always"`
                        showExpandedAbbreviation = "always",
                        --- @type boolean Defaults to `false`
                        showSuggestionsAsSnippets = false,
                        --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/syntax-profiles/)
                        syntaxProfiles = {},
                        --- @type table<string, string> [Emmet Docs](https://docs.emmet.io/customization/snippets/#variables)
                        variables = {},
                    },
                })
            end,
            ["marksman"] = function()
                lspconfig["marksman"].setup({
                    capabilities = capabilities,
                    on_attach = function(client, bufnr)
                        -- Apply Markdown-specific settings
                        if vim.bo[bufnr].filetype == "markdown" then
                            -- Set textwidth to 80 for Markdown
                            vim.bo[bufnr].textwidth = 80
                            -- Optional: Automatically wrap text while typing
                            vim.bo[bufnr].formatoptions = vim.bo[bufnr].formatoptions .. "t"
                        end
                    end,
                })
            end,
            ["ts_ls"] = function()
                lspconfig.ts_ls.setup({
                    capabilities = capabilities,
                    on_attach = function(client, bufnr)
                        -- Disable formatting if you're using a separate formatter like Prettier
                        -- client.server_capabilities.documentFormattingProvider = false
                    end,
                    init_options = {
                        preferences = {
                            includeCompletionsWithSnippetText = true,
                            includeCompletionsForImportStatements = true,
                        },
                    },
                })
            end,
        })
    end,
}
