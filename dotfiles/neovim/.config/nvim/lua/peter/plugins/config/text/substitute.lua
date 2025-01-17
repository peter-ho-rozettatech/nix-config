return {
    "gbprod/substitute.nvim",
    keys = {
        { "<leader>s", "<CMD>lua require('substitute').operator()<CR>", desc = "substitute" },
        { "<leader>ss", "<CMD>lua require('substitute').line()<CR>", desc = "Line" },
        { "<leader>S", "<CMD>lua require('substitute').eol()<CR>", desc = "Substitute Eol" },
        { "<leader>s", "<CMD>lua require('substitute').visual()<CR>", mode = "x", desc = "Substitute" },
        { "\\s", "<CMD>lua require('substitute.range').operator()<CR>", desc = "Substitute" },
        { "\\s", "<CMD>lua require('substitute.range').visual()<CR>", mode = "x", desc = "Substitute" },
        { "\\ss", "<CMD>lua require('substitute.range').word()<CR>", desc = "Word" },
        { "\\S", "<CMD>lua require('substitute.range').operator({ prefix = 'S' })<CR>", desc = "Subvert" },
        { "\\S", "<CMD>lua require('substitute.range').visual({ prefix = 'S' })<CR>", mode = "x", desc = "Subvert" },
        { "\\SS", "<CMD>lua require('substitute.range').word({ prefix = 'S' })<CR>", desc = "Word" },
        { "cx", "<CMD>lua require('substitute.exchange').operator()<CR>", desc = "Exchange" },
        { "cxx", "<CMD>lua require('substitute.exchange').line()<CR>", desc = "Line" },
        { "X", "<CMD>lua require('substitute.exchange').visual()<CR>", mode = "x", desc = "Exchange" },
        { "cxc", "<CMD>lua require('substitute.exchange').cancel()<CR>", desc = "Cancel" },
    },
    config = function()
        require("substitute").setup({
            on_substitute = require("yanky.integration").substitute(),
        })
    end,
}
