return {
    "petertriho/nvim-scrollbar",
    -- dir = "~/Projects/nvim-scrollbar",
    branch = "refactor/v2",
    event = "User LazyLoadFile",
    config = function()
        local colors = require("peter.plugins.colors")

        require("scrollbar").setup({
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
            providers = {
                mini_diff = true,
            },
        })
    end,
}
