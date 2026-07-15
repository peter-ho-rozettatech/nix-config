return {
    condition = function()
        return vim.b.minigit_summary ~= nil
    end,
    update = { "User", pattern = { "MiniGitUpdated", "MiniDiffUpdated" } },
    init = function(self)
        self.git_summary = vim.b.minigit_summary or {}
        self.diff_summary = vim.b.minidiff_summary or {}
    end,
    {
        provider = function(self)
            local branch = self.git_summary.head_name
            return branch and (" " .. branch .. " ") or ""
        end,
        hl = { bold = true },
    },
    {
        provider = function(self)
            local count = self.diff_summary.add or 0
            return count > 0 and ("+" .. count .. " ")
        end,
        hl = { fg = "git_add" },
    },
    {
        provider = function(self)
            local count = self.diff_summary.delete or 0
            return count > 0 and ("-" .. count .. " ")
        end,
        hl = { fg = "git_del" },
    },
    {
        provider = function(self)
            local count = self.diff_summary.change or 0
            return count > 0 and ("~" .. count .. " ")
        end,
        hl = { fg = "git_change" },
    },
}
