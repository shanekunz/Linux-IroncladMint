-- .NET Test Runner keybindings
return {
  "mfussenegger/nvim-dap",
  keys = {
    {
      "<leader>dT",
      function()
        require("utils.dotnet-test").pick_test(true)
      end,
      desc = "Debug .NET Test (pick)",
    },
    {
      "<leader>dR",
      function()
        require("utils.dotnet-test").pick_test(false)
      end,
      desc = "Run .NET Test (pick)",
    },
    {
      "<leader>dX",
      function()
        require("utils.dotnet-test").clear_cache()
      end,
      desc = "Clear test cache",
    },
  },
}
