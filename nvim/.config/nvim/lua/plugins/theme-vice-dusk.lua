return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = function(_, opts)
      opts.style = "moon"
      opts.transparent = false
      opts.terminal_colors = true

      opts.on_colors = function(c)
        c.bg = "#201124"
        c.bg_dark = "#1a0f1f"
        c.bg_float = "#2a1530"
        c.bg_sidebar = "#1a0f1f"

        c.fg = "#f4ecff"
        c.fg_dark = "#d7c1f4"
        c.fg_gutter = "#8865ad"

        c.comment = "#8e6db1"

        c.blue = "#9a8cff"
        c.cyan = "#b07cff"
        c.green = "#d6b86a"
        c.magenta = "#d782ff"
        c.purple = "#b96dff"
        c.yellow = "#ffce73"
        c.orange = "#ff9f1c"
        c.red = "#ff6cae"

        c.border = "#5c2f6e"
        c.border_highlight = "#ff9f1c"

        c.bg_highlight = "#3a1f45"
        c.bg_search = "#ff9f1c"
        c.bg_visual = "#4c265c"
      end

      opts.on_highlights = function(hl, c)
        hl.Visual = { bg = "#4f275f" }
        hl.Search = { fg = "#1a0f1f", bg = c.orange, bold = true }
        hl.IncSearch = { fg = "#1a0f1f", bg = "#ffb347", bold = true }
        hl.CurSearch = { fg = "#1a0f1f", bg = c.orange, bold = true }

        hl.CursorLine = { bg = "#341c40" }
        hl.CursorLineNr = { fg = c.orange, bold = true }

        hl.Pmenu = { fg = c.fg, bg = "#2a1530" }
        hl.PmenuSel = { fg = "#1a0f1f", bg = c.orange, bold = true }

        hl.TelescopeSelection = { fg = c.fg, bg = "#3b1f48", bold = true }
        hl.TelescopeMatching = { fg = c.orange, bold = true }

        hl.WinSeparator = { fg = "#5c2f6e" }
        hl.FloatBorder = { fg = c.border_highlight }

        hl.DiagnosticVirtualTextError = { fg = "#ff97c8", bg = "#331325" }
        hl.DiagnosticVirtualTextWarn = { fg = "#ffd48a", bg = "#35250e" }
        hl.DiagnosticVirtualTextInfo = { fg = "#d5c7ff", bg = "#241538" }
        hl.DiagnosticVirtualTextHint = { fg = "#f0cd87", bg = "#362612" }
      end
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local vice = {
        bg_base = "#2a1530",
        bg_mid = "#3a1f45",
        bg_strong = "#4c265c",
        fg = "#f4ecff",
        fg_muted = "#d7c1f4",
        orange = "#ff9f1c",
        purple = "#b96dff",
        magenta = "#d782ff",
        pink = "#ff6cae",
        amber = "#ffb347",
      }

      opts.options = opts.options or {}
      opts.options.theme = {
        normal = {
          a = { fg = "#1a0f1f", bg = vice.orange, bold = true },
          b = { fg = vice.fg, bg = vice.bg_strong },
          c = { fg = vice.fg_muted, bg = vice.bg_mid },
        },
        insert = {
          a = { fg = "#1a0f1f", bg = vice.purple, bold = true },
          b = { fg = vice.fg, bg = vice.bg_strong },
          c = { fg = vice.fg_muted, bg = vice.bg_mid },
        },
        visual = {
          a = { fg = "#1a0f1f", bg = vice.magenta, bold = true },
          b = { fg = vice.fg, bg = vice.bg_strong },
          c = { fg = vice.fg_muted, bg = vice.bg_mid },
        },
        replace = {
          a = { fg = "#1a0f1f", bg = vice.pink, bold = true },
          b = { fg = vice.fg, bg = vice.bg_strong },
          c = { fg = vice.fg_muted, bg = vice.bg_mid },
        },
        command = {
          a = { fg = "#1a0f1f", bg = vice.amber, bold = true },
          b = { fg = vice.fg, bg = vice.bg_strong },
          c = { fg = vice.fg_muted, bg = vice.bg_mid },
        },
        inactive = {
          a = { fg = vice.fg_muted, bg = vice.bg_base },
          b = { fg = vice.fg_muted, bg = vice.bg_base },
          c = { fg = vice.fg_muted, bg = vice.bg_base },
        },
      }
    end,
  },
}
