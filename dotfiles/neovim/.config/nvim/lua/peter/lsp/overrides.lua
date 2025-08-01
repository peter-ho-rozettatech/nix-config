local vtsls_setup = function(config)
    -- NOTE: workaround for https://yarnpkg.com/getting-started/editor-sdks
    local yarn_sdks = vim.fs.find({ "sdks" }, { type = "directory", path = ".yarn" })
    if #yarn_sdks > 0 then
        config.settings.vtsls.typescript = {
            globalTsdk = "./.yarn/sdks/typescript/lib",
        }
    end

    return config
end

return {
    basedpyright = {
        settings = {
            basedpyright = {
                analysis = {
                    autoSearchPaths = true,
                    diagnosticMode = "workspace",
                    useLibraryCodeForTypes = true,
                    typeCheckingMode = "off",
                    ignore = { "*" },
                    diagnosticSeverityOverrides = {
                        reportGeneralTypeIssues = "information",
                    },
                },
            },
        },
        on_attach = function(client, bufnr)
            vim.keymap.set("n", "gro", "<CMD>PyrightOrganizeImports<CR>", { buffer = bufnr, desc = "Organize Imports" })
        end,
    },
    bashls = {},
    cssls = {},
    dockerls = {},
    docker_compose_language_service = {},
    -- emmet_language_server = {
    --     filetypes = {
    --         "css",
    --         "eruby",
    --         "html",
    --         "htmldjango",
    --         "javascriptreact",
    --         "less",
    --         "pug",
    --         "sass",
    --         "scss",
    --         "typescriptreact",
    --         "htmlangular",
    --         -- additional filetypes
    --         "javascript",
    --         "javascript.jsx",
    --         "typescript",
    --         "typescript.tsx",
    --         "xml",
    --     },
    -- },
    eslint = {},
    fish_lsp = {},
    gopls = {},
    harper_ls = {},
    html = {
        init_options = {
            provideFormatter = false,
        },
    },
    jdtls = {},
    jsonls = {
        init_options = {
            provideFormatter = false,
        },
        settings = {
            json = {
                validate = { enable = true },
                schemas = require("schemastore").json.schemas(),
            },
        },
    },
    lua_ls = {},
    marksman = {},
    nil_ls = {
        settings = {
            ["nil"] = {
                nix = {
                    flake = {
                        autoArchive = false,
                    },
                },
            },
        },
    },
    postgres_lsp = {},
    -- pyrefly = {},
    quick_lint_js = {
        filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
        },
    },
    ruff = {
        capabilities = {
            general = {
                positionEncodings = { "utf-16" },
            },
        },
        init_options = {
            settings = {
                configuration = vim.fn.expand("$HOME/.config/nvim/code/ruff.toml"),
            },
        },
        on_attach = function(client, bufnr)
            vim.api.nvim_buf_create_user_command(bufnr, "RuffAutoFix", function()
                client:exec_cmd({
                    command = "ruff.applyAutofix",
                    arguments = {
                        { uri = vim.uri_from_bufnr(0) },
                    },
                })
            end, { desc = "Auto-fix" })

            vim.api.nvim_buf_create_user_command(bufnr, "RuffOrganizeImports", function()
                client:exec_cmd({
                    command = "ruff.applyOrganizeImports",
                    arguments = { { uri = vim.uri_from_bufnr(0), version = 123 } },
                })
            end, { desc = "Organize Imports" })

            vim.keymap.set("n", "gro", "<CMD>RuffOrganizeImports<CR>", { buffer = bufnr, desc = "Organize Imports" })
        end,
    },
    rust_analyzer = {},
    -- pylyzer = {},
    superhtml = {},
    svelte = {},
    tailwindcss = {},
    taplo = {},
    terraformls = {},
    tflint = {},
    -- ts_ls = {
    --     on_attach = function(client, bufnr)
    --         vim.api.nvim_buf_create_user_command(bufnr, "TSServerOrganizeImports", function()
    --             client:exec_cmd({
    --                 command = "_typescript.organizeImports",
    --                 arguments = { vim.api.nvim_buf_get_name(0) },
    --             })
    --         end, { desc = "Organize Imports" })
    --
    --         vim.keymap.set(
    --             "n",
    --             "gro",
    --             "<CMD>TSServerOrganizeImports<CR>",
    --             { buffer = bufnr, desc = "Organize Imports" }
    --         )
    --     end,
    -- },
    -- ty = {},
    typos_lsp = {
        init_options = {
            diagnosticSeverity = "information",
        },
    },
    vtsls = vtsls_setup({
        init_options = {
            hostInfo = "neovim",
        },
        settings = {
            vtsls = {
                autoUserWorkspaceTsdk = true,
                experimental = {
                    completion = { enableServerSideFuzzyMatch = true },
                },
            },
        },
        on_attach = function(client, bufnr)
            vim.api.nvim_buf_create_user_command(bufnr, "VtslsOrganizeImports", function()
                client:exec_cmd({
                    command = "typescript.organizeImports",
                    arguments = { vim.api.nvim_buf_get_name(0) },
                })
            end, { desc = "Organize Imports" })

            vim.keymap.set("n", "gro", "<CMD>VtslsOrganizeImports<CR>", { buffer = bufnr, desc = "Organize Imports" })
        end,
    }),
    yamlls = require("yaml-companion").setup({ lspconfig = {} }),
}
