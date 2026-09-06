-- One-time arborist cleanup, then `:TSUpdateSync` (or `nixcfg nvim`):
--   ~/.local/share/nvim/site/parser/*
--   ~/.local/share/nvim/site/queries/*
--   ~/.cache/nvim/arborist
--   ~/.local/share/nvim/arborist-lock.json
return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    cmd = {
        "TSUpdate",
        "TSUpdateSync",
    },
    event = { "User LazyLoadFile", "VeryLazy" },
    config = function()
        local ensure_installed = {
            "markdown_inline",
            "regex",
            "vimdoc",
            unpack(require("peter.core.filetypes").treesitter),
        }

        local ok, nvim_treesitter = pcall(require, "nvim-treesitter")
        if not ok then
            return
        end
        nvim_treesitter.install(ensure_installed)

        -- Upstream `main` ships only the async `:TSUpdate`; there is no
        -- blocking `:TSUpdateSync` for headless updates, so provide one here.
        -- (Defined in `config`, not `init`: lazypack registers a `cmd` stub
        -- for `TSUpdateSync` first, and redefining it in `init` would clash
        -- with that stub.)
        vim.api.nvim_create_user_command("TSUpdateSync", function()
            require("nvim-treesitter").update():wait(600000) -- 10 mins
        end, {})

        local utils = require("peter.core.utils")

        local function enable(buf)
            if utils.is_excludes_buf(buf) or utils.file_is_big(buf) then
                return
            end

            local ft = vim.bo[buf].filetype
            if ft == "" then
                return
            end

            local lang = vim.treesitter.language.get_lang(ft)
            pcall(vim.treesitter.start, buf, lang)
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            -- vim.opt_local.foldmethod = "expr"
            -- vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
            -- vim.opt_local.foldminlines = 1
            -- vim.opt_local.foldnestmax = 3
            -- vim.opt_local.foldlevel = 3
            -- vim.opt_local.foldtext =
            --     "substitute(getline(v:foldstart),'\\t',repeat(' ',&tabstop),'g').'...'.trim(getline(v:foldend)).' ('.(v:foldend-v:foldstart+1).' lines)'"
        end

        vim.api.nvim_create_autocmd({ "FileType" }, {
            callback = function(event)
                enable(event.buf)
            end,
        })

        -- Buffers already open before the plugin lazy-loaded.
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
                enable(buf)
            end
        end
    end,
}
