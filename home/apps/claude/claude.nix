{
  config,
  lib,
  pkgs,
  ...
}:
let
  claudeCfg = config.programs.claude-code;
  settingsTarget = "${claudeCfg.configDir}/settings.json";

  # The home-manager module installs settings.json as a read-only (mode 444)
  # store symlink, so `claude` cannot persist anything it writes itself
  # (/auto-mode-setup, /config, plugin installs). We disable that link and copy
  # the generated file into place as a real writable file instead. The module
  # still evaluates the entry, so its generated output remains the single
  # source of truth for everything declared below.
  generatedSettings = config.home.file.${settingsTarget}.source;

  managedKeysFile = "${claudeCfg.configDir}/.nix-managed-keys.json";

  syncSettings = pkgs.writeShellScript "claude-code-sync-settings" ''
    set -euo pipefail
    PATH=${
      lib.makeBinPath [
        pkgs.jq
        pkgs.coreutils
      ]
    }:$PATH

    target=${lib.escapeShellArg settingsTarget}
    generated=${generatedSettings}
    keys=${lib.escapeShellArg managedKeysFile}

    mkdir -p "$(dirname "$target")"

    # A leftover store symlink from a previous generation is not writable.
    if [ -L "$target" ]; then
      rm -f "$target"
    fi

    # Fall back to the generated file alone if claude's copy is missing or
    # corrupt, rather than failing activation.
    existing=/dev/null
    if [ -f "$target" ] && jq -e . "$target" >/dev/null 2>&1; then
      existing="$target"
    fi

    prev=/dev/null
    if [ -f "$keys" ]; then
      prev="$keys"
    fi

    tmp="$(mktemp "$target.XXXXXX")"
    trap 'rm -f "$tmp"' EXIT

    # Drop keys nix used to manage but no longer does, then let nix-declared
    # values win over runtime ones. Keys claude owns are untouched.
    jq -n \
      --slurpfile existing "$existing" \
      --slurpfile generated "$generated" \
      --slurpfile prev "$prev" \
      '($existing[0] // {}) as $e
       | ($generated[0] // {}) as $g
       | ($prev[0] // []) as $p
       | ($e | delpaths($p | map([.]))) * $g' >"$tmp"

    chmod 644 "$tmp"
    mv -f "$tmp" "$target"
    trap - EXIT

    jq -n --slurpfile generated "$generated" '$generated[0] // {} | keys' >"$keys.tmp"
    mv -f "$keys.tmp" "$keys"
  '';
in
{
  programs.mcp = {
    enable = true;
    servers.icon-composer = {
      command = "${pkgs.nodejs}/bin/npx";
      args = [
        "-y"
        "-p"
        "icon-composer-mcp"
        "-c"
        ''exec ${pkgs.nodejs}/bin/node "$(readlink -f "$(command -v icon-composer-mcp)")"''
      ];
    };
  };

  programs.claude-code = {
    enable = true;

    # Pulls servers from programs.mcp.servers into Claude Code's MCP config.
    enableMcpIntegration = true;

    settings = {
      model = "opus";
      theme = "dark-daltonized";
      tui = "fullscreen";

      includeCoAuthoredBy = false;
      attribution = {
        commit = "false";
        pr = "false";
        sessionUrl = false;
      };

      extraKnownMarketplaces = {
        unifi-plugins.source = {
          source = "github";
          repo = "sirkirby/unifi-mcp";
        };

        swift-ios-skills.source = {
          source = "github";
          repo = "dpearson2699/swift-ios-skills";
        };

        claude-plugins-official.source = {
          source = "github";
          repo = "anthropics/claude-plugins-official";
        };
      };

      enabledPlugins = {
        "unifi-network@unifi-plugins" = true;

        "swiftui-skills@swift-ios-skills" = true;
        "swift-core-skills@swift-ios-skills" = true;

        "swift-lsp@claude-plugins-official" = true;
      };
    };
  };

  # Hand settings.json over to claude as a writable file (see above).
  home.file.${settingsTarget}.enable = lib.mkForce false;

  home.activation.claudeCodeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${syncSettings}
  '';
}
