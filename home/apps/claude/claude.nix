{ pkgs, ... }:
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
}
