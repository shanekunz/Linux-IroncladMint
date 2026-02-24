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

        c.blue = "#67d9f8"
        c.cyan = "#50d5ff"
        c.green = "#8ef3b3"
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
        hl.DiagnosticVirtualTextInfo = { fg = "#9defff", bg = "#122635" }
        hl.DiagnosticVirtualTextHint = { fg = "#98f9ce", bg = "#153126" }
      end
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
