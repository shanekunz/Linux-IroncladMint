return {
  "mfussenegger/nvim-dap",
  opts = function(_, opts)
    -- add or merge the adapters/configurations with whatever's already present
    local dap = require("dap")
    dap.adapters.coreclr = {
      type = 'executable',
      command = "C:/Users/Shane/AppData/Local/nvim-data/mason/packages/netcoredbg/netcoredbg/netcoredbg.exe",
      args = {'--interpreter=vscode'}
    }
    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "attach - pick process",
        request = "attach",
        processId = function()
          return require('dap.utils').pick_process()
        end,
      },
    }
    if vim.fn.has("win32") == 1 then
      vim.opt.shellslash = false
    end
  end,
}
