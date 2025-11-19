-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>d1", function()
  local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
  local cmd
  if is_windows then
    cmd = [[pwsh -NoLogo -NoProfile -Command "dotnet watch --project ViveryAscend.Admin\ViveryAscend.Admin.csproj run --urls https://localhost:7067"]]
  else
    -- Use interactive shell (-i) to load .bashrc which should have mise
    cmd = [[bash -i -c 'dotnet watch --project ViveryAscend.Admin/ViveryAscend.Admin.csproj run --urls https://localhost:7067']]
  end
  vim.cmd('tabnew')                -- Open a new tab
  vim.cmd('terminal ' .. cmd)      -- Run the terminal command
  vim.cmd('normal! G')             -- Jump to the end
  vim.cmd('tabprevious')           -- Go back to your previous tab (editor)
end, { desc = "Nectar Admin Dotnet Watch Run with Hot Reload" })

vim.keymap.set("n", "<leader>d2", function()
  local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
  local cmd
  if is_windows then
    cmd = [[pwsh -NoLogo -NoProfile -Command "dotnet watch --project ViveryAscend.API\ViveryAscend.API.csproj run --urls https://localhost:7006"]]
  else
    -- Use interactive shell (-i) to load .bashrc which should have mise
    cmd = [[bash -i -c 'dotnet watch --project ViveryAscend.API/ViveryAscend.API.csproj run --urls https://localhost:7006']]
  end
  vim.cmd('tabnew')
  vim.cmd('terminal ' .. cmd)
  vim.cmd('normal! G')
  vim.cmd('tabprevious')
end, { desc = "Nectar API Dotnet Watch Run with Hot Reload" })
