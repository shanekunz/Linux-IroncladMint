return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<leader>dD",
        "<cmd>DotnetDebugProject<cr>",
        desc = "Debug .NET Project (pick)",
      },
    },
    opts = function(_, opts)
      local dap = require("dap")
      local uv = vim.uv or vim.loop

      local selected_by_cwd = {}
      local launch_cache = nil

      local function file_exists(path)
        local stat = uv.fs_stat(path)
        return stat and stat.type == "file"
      end

      local function normalize(path)
        return vim.fs.normalize(path)
      end

      local function list_csproj()
        local cwd = vim.fn.getcwd()
        local projects = vim.fn.globpath(cwd, "**/*.csproj", false, true)
        local filtered = {}

        for _, path in ipairs(projects) do
          local normalized = normalize(path)
          if not normalized:find("/obj/", 1, true) and not normalized:find("/bin/", 1, true) then
            table.insert(filtered, normalized)
          end
        end

        table.sort(filtered)
        return filtered
      end

      local function parse_project_info(csproj)
        local content = table.concat(vim.fn.readfile(csproj), "\n")
        local name = content:match("<AssemblyName>%s*(.-)%s*</AssemblyName>")
        local tfm = content:match("<TargetFramework>%s*(.-)%s*</TargetFramework>")

        if not tfm then
          local tfms = content:match("<TargetFrameworks>%s*(.-)%s*</TargetFrameworks>")
          if tfms then
            tfm = vim.split(tfms, ";", { plain = true })[1]
          end
        end

        if not name or name == "" then
          name = vim.fn.fnamemodify(csproj, ":t:r")
        end

        return {
          assembly_name = name,
          target_framework = tfm,
        }
      end

      local function parse_launch_settings(project_dir)
        local launch_file = normalize(project_dir .. "/Properties/launchSettings.json")
        if not file_exists(launch_file) then
          return { args = {}, env = {} }
        end

        local ok, parsed = pcall(vim.json.decode, table.concat(vim.fn.readfile(launch_file), "\n"))
        if not ok or type(parsed) ~= "table" or type(parsed.profiles) ~= "table" then
          return { args = {}, env = {} }
        end

        local chosen = nil
        for _, profile in pairs(parsed.profiles) do
          if type(profile) == "table" and profile.commandName == "Project" then
            chosen = profile
            break
          end
        end
        if not chosen then
          for _, profile in pairs(parsed.profiles) do
            if type(profile) == "table" then
              chosen = profile
              break
            end
          end
        end
        if not chosen then
          return { args = {}, env = {} }
        end

        local env = {}
        if type(chosen.environmentVariables) == "table" then
          for k, v in pairs(chosen.environmentVariables) do
            env[k] = tostring(v)
          end
        end

        if type(chosen.applicationUrl) == "string" and chosen.applicationUrl ~= "" then
          env.ASPNETCORE_URLS = chosen.applicationUrl
        end

        local args = {}
        if type(chosen.commandLineArgs) == "string" and chosen.commandLineArgs ~= "" then
          args = vim.split(chosen.commandLineArgs, "%s+", { trimempty = true })
        end

        return {
          args = args,
          env = env,
        }
      end

      local function select_project(projects, callback)
        if #projects == 0 then
          callback(nil)
          return
        end

        local cwd = normalize(vim.fn.getcwd())
        local items = {}
        local default_idx = 1

        for _, p in ipairs(projects) do
          local rel = vim.fn.fnamemodify(p, ":.")
          table.insert(items, {
            text = rel,
            project = p,
          })
        end

        if selected_by_cwd[cwd] then
          for i, item in ipairs(items) do
            if item.project == selected_by_cwd[cwd] then
              default_idx = i
              break
            end
          end
        end

        local ok, snacks = pcall(require, "snacks")
        if ok and snacks.picker then
          snacks.picker.pick({
            title = "Debug .NET Project",
            items = items,
            format = function(item)
              return {
                { item.text },
              }
            end,
            confirm = function(picker, item)
              picker:close()
              local project = item and item.project or nil
              if project then
                selected_by_cwd[cwd] = project
              end
              callback(project)
            end,
          })
          return
        end

        vim.ui.select(items, {
          prompt = "Debug .NET Project",
          format_item = function(item)
            return item.text
          end,
        }, function(choice)
          local project = choice and choice.project or nil
          if project then
            selected_by_cwd[cwd] = project
          end
          callback(project)
        end)
      end

      local function select_project_sync(projects)
        if #projects == 0 then
          return nil
        end

        local cwd = normalize(vim.fn.getcwd())
        local display = {}
        local by_index = {}

        for i, p in ipairs(projects) do
          local rel = vim.fn.fnamemodify(p, ":.")
          display[i] = string.format("%d. %s", i, rel)
          by_index[i] = p
        end

        local prompt = { "Select .csproj to debug:" }
        vim.list_extend(prompt, display)
        local choice = vim.fn.inputlist(prompt)
        if choice < 1 or choice > #projects then
          return nil
        end

        selected_by_cwd[cwd] = by_index[choice]
        return by_index[choice]
      end

      local function build_project(csproj)
        local output = vim.fn.system({ "dotnet", "build", csproj, "-c", "Debug", "--nologo" })
        if vim.v.shell_error ~= 0 then
          vim.notify("dotnet build failed:\n" .. output:sub(1, 1200), vim.log.levels.ERROR)
          return false
        end
        return true
      end

      local function resolve_dll(project_dir, assembly_name, target_framework)
        if target_framework and target_framework ~= "" then
          local expected = normalize(project_dir .. "/bin/Debug/" .. target_framework .. "/" .. assembly_name .. ".dll")
          if file_exists(expected) then
            return expected
          end
        end

        local fallback = vim.fn.globpath(project_dir, "bin/Debug/**/*.dll", false, true)
        for _, path in ipairs(fallback) do
          local normalized = normalize(path)
          if normalized:sub(-(#assembly_name + 4)) == (assembly_name .. ".dll") then
            return normalized
          end
        end

        return nil
      end

      local function prepare_launch(pick_new)
        if launch_cache and not pick_new then
          return launch_cache
        end

        local projects = list_csproj()
        if #projects == 0 then
          vim.notify("No .csproj files found under current directory", vim.log.levels.ERROR)
          return nil
        end

        local cwd = normalize(vim.fn.getcwd())
        local csproj = nil
        if pick_new then
          csproj = select_project_sync(projects)
        else
          csproj = selected_by_cwd[cwd]
          if not csproj or not vim.tbl_contains(projects, csproj) then
            csproj = select_project_sync(projects)
          end
        end

        if not csproj then
          vim.notify("Debug launch cancelled", vim.log.levels.WARN)
          return nil
        end

        if not build_project(csproj) then
          return nil
        end

        local project_dir = normalize(vim.fn.fnamemodify(csproj, ":h"))
        local info = parse_project_info(csproj)
        local dll = resolve_dll(project_dir, info.assembly_name, info.target_framework)
        if not dll then
          vim.notify("Could not locate compiled DLL for " .. info.assembly_name, vim.log.levels.ERROR)
          return nil
        end

        local launch_settings = parse_launch_settings(project_dir)
        launch_cache = {
          program = dll,
          cwd = project_dir,
          args = launch_settings.args,
          env = launch_settings.env,
          project = csproj,
        }

        vim.notify("Debugging " .. vim.fn.fnamemodify(csproj, ":."), vim.log.levels.INFO)
        return launch_cache
      end

      local function start_debug_for_project(csproj)
        if not csproj then
          vim.notify("Debug launch cancelled", vim.log.levels.WARN)
          return
        end

        if not build_project(csproj) then
          return
        end

        local project_dir = normalize(vim.fn.fnamemodify(csproj, ":h"))
        local info = parse_project_info(csproj)
        local dll = resolve_dll(project_dir, info.assembly_name, info.target_framework)
        if not dll then
          vim.notify("Could not locate compiled DLL for " .. info.assembly_name, vim.log.levels.ERROR)
          return
        end

        local launch_settings = parse_launch_settings(project_dir)

        dap.run({
          type = "coreclr",
          name = "launch - pick csproj",
          request = "launch",
          program = dll,
          cwd = project_dir,
          env = launch_settings.env,
          args = launch_settings.args,
          stopAtEntry = false,
        })

        vim.notify("Debugging " .. vim.fn.fnamemodify(csproj, ":."), vim.log.levels.INFO)
      end

      local mason_dbg = normalize(vim.fn.stdpath("data") .. "/mason/bin/netcoredbg")
      local netcoredbg_cmd = vim.fn.executable(mason_dbg) == 1 and mason_dbg or "netcoredbg"

      dap.adapters.coreclr = {
        type = "executable",
        command = netcoredbg_cmd,
        args = { "--interpreter=vscode" },
      }

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - pick csproj",
          request = "launch",
          program = function()
            local launch = prepare_launch(true)
            return launch and launch.program or nil
          end,
          cwd = function()
            local launch = prepare_launch(false)
            return launch and launch.cwd or vim.fn.getcwd()
          end,
          env = function()
            local launch = prepare_launch(false)
            return launch and launch.env or {}
          end,
          args = function()
            local launch = prepare_launch(false)
            return launch and launch.args or {}
          end,
          stopAtEntry = false,
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

      dap.listeners.after.event_terminated["dotnet_launch_cleanup"] = function()
        launch_cache = nil
      end
      dap.listeners.after.event_exited["dotnet_launch_cleanup"] = function()
        launch_cache = nil
      end

      vim.api.nvim_create_user_command("DotnetDebugProject", function()
        local projects = list_csproj()
        if #projects == 0 then
          vim.notify("No .csproj files found under current directory", vim.log.levels.ERROR)
          return
        end
        select_project(projects, function(csproj)
          if csproj then
            start_debug_for_project(csproj)
          end
        end)
      end, {
        desc = "Pick .csproj and launch .NET debugger",
      })

      if vim.fn.executable(netcoredbg_cmd) ~= 1 then
        vim.schedule(function()
          local ok, registry = pcall(require, "mason-registry")
          if ok then
            local ok_pkg, pkg = pcall(registry.get_package, "netcoredbg")
            if ok_pkg and pkg and not pkg:is_installed() then
              vim.notify("Installing netcoredbg via Mason...", vim.log.levels.INFO)
              pkg:install()
              return
            end
          end
          vim.notify("netcoredbg not found. Install with :MasonInstall netcoredbg", vim.log.levels.WARN)
        end)
      end

      if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
        vim.opt.shellslash = false
      end
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "netcoredbg") then
        table.insert(opts.ensure_installed, "netcoredbg")
      end
    end,
  },
}
