-- Thrax for Neovim (0.10+): the `thrax` filetype and the `thrax lsp` server.
--
-- Install: put this file on your runtimepath as `lua/thrax.lua` (or copy it
-- into your config) and call `require("thrax").setup()`. Options (all
-- optional) are the `lsp` options a project's `BUILD.thx` sets, and override it:
--
--   require("thrax").setup({ settings = { lsp = { check = "save", focus = "one" } } })
--
-- The server marks each diagnostic with a role in `data.role`: `focus` (the
-- error that matters most), `root`, `consequence`, `grace`, `lint`. The
-- severities already encode it; the highlights below make the focus stand out
-- and quiet the rest.

local M = {}

function M.setup(opts)
  opts = opts or {}
  vim.filetype.add({ extension = { thx = "thrax" } })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "thrax",
    callback = function(args)
      vim.bo[args.buf].commentstring = "# %s"
      vim.bo[args.buf].expandtab = true
      vim.bo[args.buf].shiftwidth = 4
      vim.bo[args.buf].tabstop = 4
      vim.lsp.start({
        name = "thrax",
        cmd = opts.cmd or { "thrax", "lsp" },
        root_dir = vim.fs.root(args.buf, { "BUILD.thx", ".git" }) or vim.fn.getcwd(),
        init_options = opts.settings or {},
        settings = { thrax = opts.settings or {} },
      })
      if opts.format_on_save then
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = args.buf,
          callback = function() vim.lsp.buf.format({ name = "thrax" }) end,
        })
      end
    end,
  })

  -- One loud error, the rest quiet: list the focus first, mark only errors in
  -- the sign column, and show only the focus inline.
  vim.diagnostic.config({
    severity_sort = true,
    signs = { severity = { min = vim.diagnostic.severity.WARN } },
    underline = true,
    virtual_text = {
      severity = { min = vim.diagnostic.severity.ERROR },
      format = function(d)
        local role = d.user_data and d.user_data.lsp and d.user_data.lsp.data and d.user_data.lsp.data.role
        if role ~= "focus" then return nil end
        return (d.message:gsub("\n.*", ""))
      end,
    },
    float = { source = true },
  })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { undercurl = false, underdotted = true, sp = "Gray" })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { undercurl = false, underdotted = true, sp = "DarkGray" })
end

return M
