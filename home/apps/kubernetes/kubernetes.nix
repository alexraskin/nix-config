{ pkgs, ... }:
let
  kubeconfig-sync = pkgs.writeShellApplication {
    name = "kubeconfig-sync";
    runtimeInputs = [
      pkgs.jq
      pkgs.coreutils
    ];
    text = ''
      vault="''${1:-Private}"
      dest="$HOME/.kube/configs"

      if ! command -v op >/dev/null; then
        echo "op (1password-cli) not found" >&2
        exit 1
      fi

      mkdir -p "$dest"
      chmod 700 "$HOME/.kube" "$dest"

      items=$(op item list --vault "$vault" --categories Document \
        --tags kubeconfig --format json)

      count=$(jq length <<<"$items")
      if [[ "$count" -eq 0 ]]; then
        echo "no documents tagged 'kubeconfig' in vault '$vault'" >&2
        exit 1
      fi

      jq -r '.[] | [.id, .title] | @tsv' <<<"$items" |
        while IFS=$'\t' read -r id title; do
          out="$dest/''${title}.yaml"
          op document get "$id" --vault "$vault" --out-file "$out" --force
          echo "==> $out"
        done

      echo "open a new shell (or re-source ~/.zshrc) to pick up new files"
    '';
  };
in
{
  home.packages = with pkgs; [
    kubectl
    kubectx # kubectx / kubens for switching context and namespace
    kubeconfig-sync
  ];

  programs.k9s = {
    enable = true;
    settings.k9s = {
      refreshRate = 2;
      skipLatestRevCheck = true;
    };
  };

  home.shellAliases = {
    k = "kubectl";
    kx = "kubectx";
    kn = "kubens";
  };

  # kubectl ships share/zsh/site-functions/_kubectl, and the zsh module already
  # folds every NIX_PROFILE's site-functions onto fpath, so completion needs no
  # `kubectl completion zsh` eval at startup. The compdef only teaches zsh that
  # the alias is kubectl.
  #
  # KUBECONFIG is a tied array so it stays a colon-separated list: ~/.kube/config
  # first (cloud CLIs and `kubectl config` write there), then anything synced out
  # of 1Password. (N) makes the glob vanish when the directory is empty.
  programs.zsh.initContent = ''
    compdef k=kubectl

    if [[ -z ''${kubeconfig+x} ]]; then
      typeset -TUx KUBECONFIG kubeconfig ':'
    fi
    kubeconfig=(~/.kube/config(N) ~/.kube/configs/*.yaml(N))
  '';
}
