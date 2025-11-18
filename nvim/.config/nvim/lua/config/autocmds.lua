-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dap-float",
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "n", "q", "<cmd>close!<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, "n", "<Esc>", "<cmd>close!<CR>", { noremap = true, silent = true })
  end
})

vim.api.nvim_create_user_command('EditSecrets', function()
  -- Find all .csproj files recursively from the current directory
  local csprojs = vim.fn.glob('**/*.csproj', false, true)
  if #csprojs == 0 then
    vim.notify("No .csproj files found in or under current directory", vim.log.levels.ERROR)
    return
  end

  local function open_secrets(csproj)
    -- Extract UserSecretsId from chosen .csproj file
    local secrets_id = nil
    for line in io.lines(csproj) do
      secrets_id = string.match(line, "<UserSecretsId>(.-)</UserSecretsId>")
      if secrets_id then break end
    end
    if not secrets_id then
      vim.notify("No <UserSecretsId> found in " .. csproj, vim.log.levels.ERROR)
      return
    end

    local appdata = os.getenv("APPDATA")
    if not appdata then
      vim.notify("APPDATA environment variable not set", vim.log.levels.ERROR)
      return
    end

    local secrets_path = appdata .. "\\Microsoft\\UserSecrets\\" .. secrets_id .. "\\secrets.json"
    vim.cmd("edit " .. secrets_path)
  end

  if #csprojs == 1 then
    open_secrets(csprojs[1])
  else
    vim.ui.select(csprojs, { prompt = "Select .csproj for User Secrets:" }, function(choice)
      if choice then open_secrets(choice) end
    end)
  end
end, {
  desc = "Open the secrets.json file for a selected .NET project",
})
