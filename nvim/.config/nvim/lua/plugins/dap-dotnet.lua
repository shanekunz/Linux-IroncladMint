return {
  "mfussenegger/nvim-dap",
  opts = function(_, opts)
    local dap = require("dap")

    -- Cross-platform: Mason adds its bin/ to PATH, so just use the command name
    dap.adapters.coreclr = {
      type = "executable",
      command = "netcoredbg",
      args = { "--interpreter=vscode" },
    }

    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "launch - select dll",
        request = "launch",
        program = function()
          return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
        end,
        cwd = vim.fn.getcwd,
      },
      {
        type = "coreclr",
        name = "attach - pick process",
        request = "attach",
        processId = function()
          return require("dap.utils").pick_process()
        end,
      },
    }

    -- Windows: disable shellslash for netcoredbg path compatibility
    if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
      vim.opt.shellslash = false
    end
  end,
}
