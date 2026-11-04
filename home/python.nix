# Python with Astral's tools: uv for projects, Python versions and tools; ruff to lint and format;
# ty to type-check. Plus Neovim support.
{pkgs, ...}: {
  # In the shell too: `uv init` / `uv add` / `uv run`, `ruff check`, `ty check`.
  home.packages = with pkgs; [uv ruff ty];

  programs.nixvim = {
    lsp.servers = {
      ruff.enable = true; # lint warnings and quick fixes (gra)
      ty.enable = true; # types: completion, go to definition, hover, errors, type hints (\th)
    };

    # \cf sorts imports and formats.
    plugins.conform-nvim.settings.formatters_by_ft.python = ["ruff_organize_imports" "ruff_format"];

    plugins.treesitter.grammarPackages = [pkgs.vimPlugins.nvim-treesitter.builtGrammars.python];

    # pytest under neotest (\n…). In a uv project (has uv.lock) tests run with `uv run`, which
    # syncs .venv first; elsewhere the project's virtualenv is found as usual.
    plugins.neotest.adapters.python = {
      enable = true;
      settings = {
        runner = "pytest";
        python.__raw = ''
          function(root)
            root = root or vim.uv.cwd()
            if vim.uv.fs_stat(root .. "/uv.lock") then
              return { "${pkgs.uv}/bin/uv", "run", "--directory", root, "python" }
            end
            return require("neotest-python.base").get_python_command(root)
          end
        '';
      };
    };
  };
}
