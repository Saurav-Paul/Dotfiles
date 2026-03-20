-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>ff", function()
  Snacks.picker.files({
    hidden = true,
    ignored = true,
    exclude = { ".venv", "node_modules", ".git" },
  })
end, { desc = "Find Files" })
