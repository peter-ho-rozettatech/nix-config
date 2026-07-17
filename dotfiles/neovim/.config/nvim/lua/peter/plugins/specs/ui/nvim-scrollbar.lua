return {
    "petertriho/nvim-scrollbar",
    -- dir = "~/Projects/nvim-scrollbar",
    branch = "refactor/v2",
    event = "User LazyLoadFile",
    config = function()
        local colors = require("peter.plugins.colors")

        require("scrollbar").setup({
            float = { placement = { anchor = "NW" } },
            layout = { direction = "auto", columns = { { "track", "thumb", "marks" } } },
            -- folds = false,
            -- handle = {
            --     blend = 10,
            -- },
            marks = {
                Search = { highlight = { fg = colors.orange } },
                GitAdd = { text = "│" },
                GitChange = { text = "│" },
                GitDelete = { text = "│" },
                MiniDiffAdd = { text = "│" },
                MiniDiffChange = { text = "│" },
                MiniDiffDelete = { text = "│" },
            },
            excluded_filetypes = require("peter.core.filetypes").excludes,
            -- handlers = {
            --     search = true,
            -- },
            providers = {
                -- gitsigns = true,
                mini_diff = true,
            },
            -- autohide = {
            --     enabled = true,
            -- },
        })
    end,
}
