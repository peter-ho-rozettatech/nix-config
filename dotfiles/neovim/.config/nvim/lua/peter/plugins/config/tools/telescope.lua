return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
        -- { "<leader>;", "<CMD>Telescope find_files hidden=true<CR>", desc = "Find Files" },
        { "<leader>o;", "<CMD>Telescope yaml_schema<CR>", desc = "Yaml Schema" },
        -- { "<leader>'", "<CMD>Telescope live_grep<CR>", desc = "Live Grep" },
        {
            "<leader>ln",
            "<CMD>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>",
            desc = "Dynamic Workspace Symbols",
        },
        { "<leader>m", "<CMD>Telescope marks<CR>", desc = "Marks" },
        { "<leader>gb", "<CMD>lua require('telescope.builtin').git_branches()<CR>", desc = "Branches" },
        { "<leader>gc", "<CMD>lua require('telescope.builtin').git_commits()<CR>", desc = "Commits" },
        { "<leader>gs", "<CMD>lua require('telescope.builtin').git_stashes()<CR>", desc = "Stashes" },
        { "<leader>ta", "<CMD>Telescope find_files find_command=fd,-HIL<CR>", desc = "Find Files All" },
        { "<leader>tb", "<CMD>Telescope scope buffers<CR>", desc = "Buffers" },
        { "<leader>tc", "<CMD>Telescope commands<CR>", desc = "Commands" },
        { "<leader>th", "<CMD>Telescope help_tags<CR>", desc = "Help Tags" },
        { "<leader>tj", "<CMD>Telescope jumplist<CR>", desc = "Command History" },
        { "<leader>tm", "<CMD>Telescope man_pages<CR>", desc = "Man Pages" },
        { "<leader>to", "<CMD>Telescope oldfiles<CR>", desc = "Old Files" },
        { "<leader>ty", "<CMD>Telescope yank_history<CR>", desc = "Yank History" },
        {
            "<leader>ld",
            "<CMD>lua require('telescope.builtin').lsp_definitions({ jump_type = 'never' })<CR>",
            desc = "Definitions",
        },
        { "<leader>le", "<CMD>lua require('telescope.builtin').diagnostics()<CR>", desc = "Errors" },
        {
            "<leader>li",
            "<CMD>lua require('telescope.builtin').lsp_implementations({ jump_type = 'never' })<CR>",
            desc = "Implementations",
        },
        {
            "<leader>ln",
            "<CMD>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>",
            desc = "Dynamic Workspace Symbols",
        },
        { "<leader>lr", "<CMD>lua require('telescope.builtin').lsp_references()<CR>", desc = "References" },
        { "<leader>ls", "<CMD>lua require('telescope.builtin').lsp_document_symbols()<CR>", desc = "Document Symbols" },
        {
            "<leader>lw",
            "<CMD>lua require('telescope.builtin').lsp_workspace_symbols()<CR>",
            desc = "Workspace Symbols",
        },
        {
            "<leader>ly",
            "<CMD>lua require('telescope.builtin').lsp_type_definitions({ jump_type = 'never' })<CR>",
            desc = "Type Definitions",
        },
    },
    config = function()
        local telescope = require("telescope")
        local actions_layout = require("telescope.actions.layout")

        local function flash(prompt_bufnr)
            require("flash").jump({
                pattern = "^",
                label = { after = { 0, 0 } },
                search = {
                    mode = "search",
                    exclude = {
                        function(win)
                            return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
                        end,
                    },
                    multi_window = true,
                },
                action = function(match)
                    local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
                    picker:set_selection(match.pos[1] - 1)
                end,
            })
        end

        telescope.setup({
            defaults = {
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--hidden",
                },
                prompt_prefix = "   ",
                selection_caret = "  ",
                mappings = {
                    i = {
                        ["<C-l>"] = actions_layout.toggle_preview,
                        ["<c-s>"] = flash,
                    },
                    n = {
                        ["<C-l>"] = actions_layout.toggle_preview,
                        s = flash,
                    },
                },
                history = false,
                file_ignore_patterns = vim.opt.wildignore:get(),
                sorting_strategy = "ascending",
                layout_strategy = "flex",
                layout_config = {
                    horizontal = { preview_width = 0.6, prompt_position = "top" },
                    vertical = { mirror = true },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = false,
                    override_file_sorter = true,
                    case_mode = "smart_case",
                },
                undo = {
                    use_delta = true,
                    side_by_side = true,
                },
            },
            pickers = {
                file_browser = {
                    hidden = true,
                },
                find_files = {
                    hidden = true,
                    attach_mappings = function()
                        require("telescope.actions.set").select:enhance({
                            post = function()
                                vim.cmd(":normal! zx")
                            end,
                        })
                        return true
                    end,
                },
            },
        })

        telescope.load_extension("fzf")
        -- telescope.load_extension("yaml_schema")
    end,
}
