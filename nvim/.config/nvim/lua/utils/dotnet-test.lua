-- .NET Test Runner with Debug Support
-- Discovers tests across multiple projects and allows running/debugging individual tests

local M = {}

-- Cache for test list (invalidated on demand)
local test_cache = nil
local cache_cwd = nil

-- Find solution file in current directory or parents
local function find_solution_file()
  local cwd = vim.fn.getcwd()

  -- Look for .sln in current dir first
  local sln_files = vim.fn.glob(cwd .. "/*.sln", false, true)
  if #sln_files > 0 then
    return sln_files[1]
  end

  -- Search parent directories
  local dir = cwd
  while dir ~= "/" do
    sln_files = vim.fn.glob(dir .. "/*.sln", false, true)
    if #sln_files > 0 then
      return sln_files[1]
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end

  return nil
end

-- Discover all tests using dotnet test --list-tests
local function discover_tests(callback)
  local cwd = vim.fn.getcwd()

  -- Return cached results if available and in same directory
  if test_cache and cache_cwd == cwd then
    callback(test_cache)
    return
  end

  local sln_file = find_solution_file()
  local cmd

  if sln_file then
    cmd = { "dotnet", "test", sln_file, "--list-tests", "--nologo" }
    vim.notify("Discovering tests from " .. vim.fn.fnamemodify(sln_file, ":t") .. "...", vim.log.levels.INFO)
  else
    cmd = { "dotnet", "test", "--list-tests", "--nologo" }
    vim.notify("Discovering tests (no .sln found, using current dir)...", vim.log.levels.INFO)
  end

  local stdout_data = {}
  local stderr_data = {}

  vim.fn.jobstart(cmd, {
    cwd = cwd,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          table.insert(stdout_data, line)
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          table.insert(stderr_data, line)
        end
      end
    end,
    on_exit = function(_, exit_code)
      -- Debug: log raw output
      if exit_code ~= 0 then
        local all_output = table.concat(stdout_data, "\n") .. "\n" .. table.concat(stderr_data, "\n")
        vim.notify("dotnet test failed (exit " .. exit_code .. "):\n" .. all_output:sub(1, 500), vim.log.levels.ERROR)
        callback({})
        return
      end

      -- Parse test names from output
      local tests = {}
      local in_test_list = false
      for _, line in ipairs(stdout_data) do
        if line:match("The following Tests are available") then
          in_test_list = true
        elseif in_test_list then
          local test_name = line:match("^%s+(.+)$")
          if test_name and test_name ~= "" then
            table.insert(tests, test_name)
          end
        end
      end

      -- Cache results
      test_cache = tests
      cache_cwd = cwd

      if #tests == 0 then
        -- Debug: show first few lines of output
        local preview = table.concat(vim.list_slice(stdout_data, 1, 5), "\n")
        vim.notify("No tests found. Output preview:\n" .. preview, vim.log.levels.WARN)
      else
        vim.notify(string.format("Found %d tests", #tests), vim.log.levels.INFO)
      end

      callback(tests)
    end,
  })
end

-- Clear the test cache
function M.clear_cache()
  test_cache = nil
  cache_cwd = nil
  vim.notify("Test cache cleared", vim.log.levels.INFO)
end

-- Run a test with optional debug
function M.run_test(test_name, debug)
  local sln_file = find_solution_file()
  local sln_arg = sln_file and string.format('"%s"', sln_file) or ""
  local filter = string.format('--filter "FullyQualifiedName~%s"', test_name)
  local base_cmd = string.format("dotnet test %s %s", sln_arg, filter)

  -- Save current position
  local original_tab = vim.api.nvim_get_current_tabpage()
  local original_win = vim.api.nvim_get_current_win()

  -- Create background tab for terminal
  vim.cmd("tabnew")

  if debug then
    local cmd = "VSTEST_HOST_DEBUG=1 " .. base_cmd
    local attached = false

    vim.fn.termopen(cmd, {
      on_stdout = function(_, data, _)
        if attached then
          return
        end
        for _, line in ipairs(data or {}) do
          local pid = line:match("Process Id:%s*(%d+)")
          if pid then
            attached = true
            vim.schedule(function()
              vim.notify("Attaching debugger to PID " .. pid, vim.log.levels.INFO)
              local dap = require("dap")
              dap.run({
                type = "coreclr",
                name = "attach",
                request = "attach",
                processId = tonumber(pid),
              })
            end)
            break
          end
        end
      end,
    })

    vim.notify("Waiting for test process...", vim.log.levels.INFO)
  else
    vim.fn.termopen(base_cmd)
  end

  -- Return to original position
  vim.api.nvim_set_current_tabpage(original_tab)
  vim.api.nvim_set_current_win(original_win)
end

-- Pick and run a test
function M.pick_test(debug)
  discover_tests(function(tests)
    if #tests == 0 then
      return
    end

    -- Use Snacks picker
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks.picker then
      snacks.picker.pick({
        title = debug and "Debug Test" or "Run Test",
        items = vim.tbl_map(function(test)
          return { text = test, value = test }
        end, tests),
        format = function(item)
          return { { item.text } }
        end,
        confirm = function(picker, item)
          picker:close()
          if item then
            M.run_test(item.value, debug)
          end
        end,
      })
    else
      -- Fallback to vim.ui.select
      vim.ui.select(tests, {
        prompt = debug and "Debug Test: " or "Run Test: ",
      }, function(choice)
        if choice then
          M.run_test(choice, debug)
        end
      end)
    end
  end)
end

return M
