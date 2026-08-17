{
  config,
  pkgs,
  lib,
  primaryUser,
  currentSystemName,
  ...
}:
let
  inherit (pkgs.stdenv) isDarwin;

  cfgDir = config.local.configDir;
  flake = "path:${cfgDir}#${currentSystemName}";

  systemsAttr = if isDarwin then "darwinConfigurations" else "nixosConfigurations";
  rebuild = if isDarwin then "darwin-rebuild" else "nixos-rebuild";
  hmPackage = "path:${cfgDir}#${systemsAttr}.${currentSystemName}.config.home-manager.users.${primaryUser}.home.activationPackage";

  commonAliases = {
    c = "claude";

    nix-switch = "sudo ${rebuild} switch --flake ${flake}";
    hm-switch = "\"$(nix build --no-link --print-out-paths '${hmPackage}')/activate\"";

    g = "git";
    gst = "git status";
    gpb = "git push -u origin $(git branch --show-current)";

    ff = "fastfetch";

    l = "ls -AF";
    ll = "ls -lh";
    la = "ls -A";

    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";

    docker-killall = "docker ps | tail -n +2 | cut -f1 -d' ' | xargs docker kill";
    docker-cleanup = "docker ps -a | cut -f1 -d' ' | tail -n +2 | xargs docker rm";
    docker-exec-latest = "docker exec -ti $(docker ps --latest --quiet) bash";

    tf = "terraform";
    tfdocs = "terraform-docs markdown table --output-file README.md --output-mode inject .";
    tflock = "terraform providers lock -platform=darwin_arm64 -platform=linux_amd64 -platform=darwin_amd64";

    rip = "${cfgDir}/bin/rip-with-ffmpeg.sh";
    rip-yt = "${cfgDir}/bin/rip-yt.sh";
    fwd = "${cfgDir}/bin/forward.sh";
  };

  darwinAliases = {
    router_ip = "route -n get default -ifscope en0 | awk '/gateway/ { print $2 }'";
    flush-dns-cache = "sudo killall -HUP mDNSResponder";
    fast = "networkQuality -v";

    tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";

    code = "zed";
  };
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 100000;
      save = 100000;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = false;
    };

    setOptions = [
      "INC_APPEND_HISTORY_TIME"
      "HIST_VERIFY"
      "HIST_REDUCE_BLANKS"
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "mise"
      ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    shellAliases = commonAliases // lib.optionalAttrs isDarwin darwinAliases;

    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        if [[ -f ~/.zshrc.local ]]; then
          source ~/.zshrc.local
        fi

        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      (lib.optionalString isDarwin ''
        # Homebrew
        eval "$(/opt/homebrew/bin/brew shellenv)"
        export HOMEBREW_NO_ENV_HINTS=1
      '')

      ''
        export GITHUB_TOKEN=$(op read "op://Private/GitHub/github-token" 2>/dev/null)

        # go
        export PATH="$HOME/go/bin:$PATH"

        # keybindings
        bindkey '^U' backward-kill-line

        # Complete ssh with hosts in ~/.ssh/config
        zstyle -s ':completion:*:hosts' hosts _ssh_config
        if [[ -r ~/.ssh/config ]]; then
          _ssh_config+=($(cat ~/.ssh/config | grep -v '\*' | sed -ne 's/Host[=\t ]//p'))
        fi
        zstyle ':completion:*:hosts' hosts $_ssh_config

        source ${./shell-functions.sh}
      ''

      (lib.mkAfter ''
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      '')
    ];
  };
}
