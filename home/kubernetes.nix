# Kubernetes tools: kubectl (coloured by kubecolor), k9s, kubectx/kubens.
{pkgs, ...}: {
  home.packages = with pkgs; [
    kubectl # also provides the zsh completion that `k` and kubecolor reuse
    kubectx # kubectx (switch cluster) and kubens (switch namespace); fzf picker when run bare
  ];

  # `kubectl` runs through kubecolor for coloured output; completion still works.
  programs.kubecolor = {
    enable = true;
    enableAlias = true;
  };

  programs.k9s.enable = true;

  programs.zsh.shellAliases.k = "kubectl";
}
