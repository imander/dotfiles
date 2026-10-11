if vim.env.SSH_TTY then
  opt.clipboard:append("unnamedplus")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = function()
        return vim.split(vim.fn.getreg(""), "\n")
      end,
      ["*"] = function()
        return vim.split(vim.fn.getreg(""), "\n")
      end,
    },
  }
end
