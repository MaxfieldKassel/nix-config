# Python with Astral's tools: uv for projects, Python versions and tools; ruff to lint and format;
# ty to type-check. Plus Neovim support.
{pkgs, ...}: {
  # In the shell too: `uv init` / `uv add` / `uv run`, `ruff check`, `ty check`.
  home.packages = with pkgs; [uv ruff ty];

  programs.nixvim = {
    # Debugging with debugpy (\d…): \dc on a file, or \nd on a test. Programs run with the
    # project's .venv (or $VIRTUAL_ENV).
    plugins.dap-python.enable = true;

    lsp.servers = {
      ruff.enable = true; # lint warnings and quick fixes (gra)
      ty.enable = true; # types: completion, go to definition, hover, errors, type hints (\th)
    };

    # \cf sorts imports and formats.
    plugins.conform-nvim.settings.formatters_by_ft.python = ["ruff_organize_imports" "ruff_format"];

    plugins.treesitter.grammarPackages = [pkgs.vimPlugins.nvim-treesitter.builtGrammars.python];

    # pytest under neotest (\n…). In a uv project (has uv.lock), .venv is synced first (only when
    # uv.lock changed; --inexact keeps packages added by hand, like `uv run`) and its python is
    # used, which debugging (\nd) needs too. Elsewhere the project's virtualenv is found as usual.
    plugins.neotest.adapters.python = {
      enable = true;
      settings = {
        runner = "pytest";
        python.__raw = ''
          (function()
            local synced = {}
            return function(root)
              root = root or vim.uv.cwd()
              local lock = vim.uv.fs_stat(root .. "/uv.lock")
              if lock then
                if synced[root] ~= lock.mtime.sec then
                  vim.system({ "${pkgs.uv}/bin/uv", "sync", "--inexact", "--quiet", "--directory", root }):wait()
                  synced[root] = lock.mtime.sec
                end
                return { root .. "/.venv/bin/python" }
              end
              return require("neotest-python.base").get_python_command(root)
            end
          end)()
        '';
      };
    };
  };
}
